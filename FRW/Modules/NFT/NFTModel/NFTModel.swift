//
//  NFTModel.swift
//  Flow Wallet
//
//  Created by cat on 2022/5/18.
//

import Foundation
import SwiftUI
import Flow

let placeholder: String = AppPlaceholder.image
// TODO: which filter?
let filterMetadata = ["uri", "img", "description"]

struct NFTCollection: Codable {
    let collection: NFTCollectionInfo
    var count: Int
    var ids: [String]?
}

struct NFTCollectionInfo: Codable, Hashable, Mockable {
    let id: String
    let name: String
    let contractName: String
    let address: String
    
    let logo: String?
    let banner: String?
    let officialWebsite: String?
    let description: String?
    
    let path: ContractPath
    
    var logoURL: URL {
        if let logoString = logo {
            return URL(string: logoString) ?? URL(string: placeholder)!
        }

        return URL(string: placeholder)!
    }
    
    var bannerURL: URL {
        if let bannerString = banner {
            return URL(string: bannerString) ?? URL(string: placeholder)!
        }

        return URL(string: placeholder)!
    }
    
    static func mock() -> NFTCollectionInfo {
        return NFTCollectionInfo(id: randomString(), name: randomString(), contractName: randomString(), address: randomString(), logo: randomString(), banner: randomString(), officialWebsite: randomString(), description: randomString(), path: ContractPath.mock())
    }
}

struct ContractPath: Codable, Hashable, Mockable {
    let storagePath: String
    let publicPath: String
    let publicCollectionName: String
    let publicType: String
    let privateType: String
    
    static func mock() -> ContractPath {
        return ContractPath(storagePath: randomString(), publicPath: randomString(), publicCollectionName: randomString(), publicType: randomString(), privateType: randomString())
    }
}

struct NFTModel: Codable, Hashable, Identifiable {
    var id: String {
        return response.uniqueId
    }

    let image: URL
    var video: URL?
    let title: String
    let subtitle: String
    var isSVG: Bool = false
    var response: NFTResponse
    let collection: NFTCollectionInfo?
    
    var imageURL: URL {
        if isSVG {
            return image.absoluteString.convertedSVGURL() ?? URL(string: placeholder)!
        } else {
              return image
        }
    }

    var isNBA: Bool {
        collection?.contractName.trim() == "TopShot"
    }
    
    init(_ response: NFTResponse, in collection: NFTCollectionInfo?) {
        if let imgUrl = response.postMedia.image, let url = URL(string: imgUrl) {
            if response.postMedia.isSvg == true {
                image = URL(string: imgUrl) ?? URL(string: placeholder)!
                isSVG = true
            } else {
                if imgUrl.hasPrefix("https://lilico.infura-ipfs.io/ipfs/") {
                    let newImgURL = imgUrl.replace(by: ["https://lilico.infura-ipfs.io/ipfs/": "https://lilico.app/api/ipfs/"])
                    image = URL(string: newImgURL)!
                } else {
                    image = url
                }
                
                isSVG = false
            }
        } else {
            image = URL(string: placeholder)!
        }

        if let videoUrl = response.postMedia.video {
            video = URL(string: videoUrl)
        }

        subtitle = response.postMedia.description ?? ""
        title = response.postMedia.title ?? response.collectionName ?? ""
        self.collection = collection
        self.response = response
    }

    var declare: String {
        if let dec = response.postMedia.description {
            return dec
        }
        return response.description ?? ""
    }

    var logoUrl: URL {
        if let logoString = collection?.logo {
            return URL(string: logoString) ?? URL(string: placeholder)!
        }
        
        return URL(string: placeholder)!
    }
    
    var collectionName: String {
        if let name = collection?.name {
            return name
        }
        
        return ""
    }

    var tags: [NFTTrait] {
        guard let traits = response.traits else {
            return []
        }
        
        return traits.filter { trait in
            !filterMetadata.contains(trait.name?.lowercased() ?? "") && !(trait.value ?? "").isEmpty && !(trait.value ?? "").hasPrefix("https://")
        }
    }
    
    var isDomain: Bool {
        if response.collectionContractName != "Domains" {
            return false
        }
        
        let name = response.name ?? ""
        let url = response.externalURL ?? ""
        
        return name.hasSuffix(".meow") || url.hasSuffix(".meow")
    }
}

class CollectionItem: Identifiable, ObservableObject {
    
    static func mock() -> CollectionItem {
        var item = CollectionItem()
        item.isEnd = true
        item.nfts = [0,1,2,3].map({ index in
            NFTModel(NFTResponse(id: "", name: "", description: "", thumbnail: "", externalURL: "", contractAddress: "", collectionID: "", collectionName: "", collectionDescription: "", collectionSquareImage: "", collectionExternalURL: "", collectionContractName: "", collectionBannerImage: "", traits: [], postMedia: NFTPostMedia(title: "", description: "", video: "", isSvg: false)), in: nil)
        })
        return item
    }
    
    var address: String = ""
    var id = UUID()
    var name: String = ""
    var collectionId: String = ""
    var count: Int = 0
    var collection: NFTCollectionInfo?
    @Published var nfts: [NFTModel] = []
    var loadCallback: ((Bool) -> ())? = nil
    var loadCallback2: ((Bool) -> ())? = nil
    
    var isEnd: Bool = false
    var isRequesting: Bool = false

    var showName: String {
        return collection?.name ?? ""
    }

    var iconURL: URL {
        if let logoString = collection?.logo {
            if logoString.hasSuffix("svg") {
                return logoString.convertedSVGURL() ?? URL(string: placeholder)!
            }
            
            return URL(string: logoString) ?? URL(string: placeholder)!
        }
        
        return URL(string: placeholder)!
    }
    
    func loadFromCache() {
        if let cachedNFTs = NFTUIKitCache.cache.getNFTs(collectionId: collectionId) {
            let models = cachedNFTs.map { NFTModel($0, in: self.collection) }
            self.nfts = models
        }
    }
    
    func load() {
        if isRequesting || isEnd {
            return
        }
        
        isRequesting = true
        
        let limit = 24
        Task {
            do {
                let response = try await requestCollectionListDetail(offset: nfts.count, limit: limit)
                DispatchQueue.main.async {
                    self.isRequesting = false
                    
                    guard let list = response.nfts, !list.isEmpty else {
                        self.isEnd = true
                        self.loadCallback?(true)
                        self.loadCallback2?(true)
                        return
                    }
                    
                    let nftModels = list.map { NFTModel($0, in: self.collection) }
                    self.appendNFTsNoDuplicated(nftModels)
                    
                    if list.count != limit {
                        self.isEnd = true
                    }
                    
                    self.saveNFTsToCache()
                    
                    self.loadCallback?(true)
                    self.loadCallback2?(true)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isRequesting = false
                    self.loadCallback?(false)
                    self.loadCallback2?(false)
                }
            }
        }
    }
    
    private func appendNFTsNoDuplicated(_ newNFTs: [NFTModel]) {
        for nft in newNFTs {
            let exist = nfts.first { $0.id == nft.id }
            
            if exist == nil {
                nfts.append(nft)
            }
        }
    }
    
    private func requestCollectionListDetail(offset: Int, limit: Int = 24) async throws -> NFTListResponse {
        let request = NFTCollectionDetailListRequest(address: address, collectionIdentifier: collection?.id ?? "", offset: offset, limit: limit)
        let response: NFTListResponse = try await Network.request(FRWAPI.NFT.collectionDetailList(request))
        return response
    }
    
    private func saveNFTsToCache() {
        let models = nfts.map { $0.response }
        NFTUIKitCache.cache.saveNFTsToCache(models, collectionId: collectionId)
    }
}
