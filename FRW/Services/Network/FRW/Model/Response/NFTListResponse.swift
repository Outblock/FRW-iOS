//
//  NFTListResponse.swift
//  Flow Wallet
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation

// MARK: - NFTListResponse
struct NFTListResponse: Codable {
    let nfts: [NFTResponse]?
    let nftCount: Int
    let info: FlowModel.CollectionInfo?
    let collection: NFTCollectionInfo?
}

extension NFTListResponse {
    func toCollectionItem() -> CollectionItem {
        let item = CollectionItem()
        item.name = info?.collectionData.display?.name ?? collection?.name ?? ""
        item.count = nftCount
        item.nfts = nfts?.compactMap({ NFTModel($0, in: collection, from: info) }) ?? []
        item.collection = collection ?? NFTCollectionInfo(id: "", name: item.name, contractName: item.name, address: "", logo: "", banner: "", officialWebsite: "", description: "", path: ContractPath(storagePath: "", publicPath: "", privatePath: nil, publicCollectionName: "", publicType: "", privateType: ""), evmAddress: nil, socials: nil, flowIdentifier: nil)
        item.isEnd = nftCount < 24
        return item
    }
}

// MARK: - NFTFavListResponse
struct NFTFavListResponse: Codable {
    let nfts: [NFTResponse]?
    let chain, network: String
    let nftcount: Int
}

// MARK: - Nft

struct NFTResponse: Codable, Hashable {
    let id: String
    let name: String?
    let description: String?
    let thumbnail: String?
    let externalURL: String?
    let contractAddress: String?
    
    let collectionID: String?
    let collectionName: String?
    let collectionDescription: String?
    let collectionSquareImage: String?
    let collectionExternalURL: String?
    let collectionContractName: String?
    let collectionBannerImage: String?
    
    let traits: [NFTTrait]?
    var postMedia: NFTPostMedia?
    
    var uniqueId: String {
        return (contractAddress ?? "") + "." + (collectionName ?? "") + "-" + "\(id)"
    }

    func cover() -> String? {
        return postMedia?.image ?? postMedia?.video ?? ""
    }

    func video() -> String? {
        return postMedia?.video ?? ""
    }
    
    static func mock() -> NFTResponse {
        NFTResponse(id: "", name: "", description: "", thumbnail: "", externalURL: "", contractAddress: "", collectionID: "", collectionName: "", collectionDescription: "", collectionSquareImage: "", collectionExternalURL: "", collectionContractName: "", collectionBannerImage: "", traits: [], postMedia: NFTPostMedia(title: "", description: "", video: "", isSvg: false))
    }
}

struct NFTRoyalty: Codable, Hashable {
    let cut: Double?
    let description: String?
}

struct NFTRoyaltyReceiver: Codable, Hashable {
    let address: String?
}

struct NFTRoyaltyReceiverPath: Codable, Hashable {
    let type: String?
    let value: NFTRoyaltyReceiverPathValue?
}

struct NFTRoyaltyReceiverPathValue: Codable, Hashable {
    let identifier: String?
    let domain: String?
}

struct NFTRoyaltyBorrowType: Codable, Hashable {
    let kind: String?
    let authorized: Bool?
    let type: NFTRoyaltyBorrowTypeType?
}

struct NFTRoyaltyBorrowTypeType: Codable, Hashable {
    let typeID: String?
    let kind: String?
    let type: NFTRoyaltyBorrowTypeTypeType?
    let restrictions: [NFTRoyaltyBorrowTypeTypeType]?
}

struct NFTRoyaltyBorrowTypeTypeType: Codable, Hashable {
    let typeID: String?
    let fields: [NFTRoyaltyBorrowTypeTypeTypeField]?
    let kind: String?
//    let type:
//    let initializers: []
}

struct NFTRoyaltyBorrowTypeTypeTypeField: Codable, Hashable {
    let id: String?
    let type: NFTRoyaltyBorrowTypeTypeTypeFieldType?
}

struct NFTRoyaltyBorrowTypeTypeTypeFieldType: Codable, Hashable {
    let kind: String?
}

struct NFTPostMedia: Codable, Hashable {
    let title: String?
    var image: String?
    let description: String?
    let video: String?
    let isSvg: Bool?
}

// MARK: - TokenMetadata

struct NFTTokenMetadata: Codable, Hashable {
    let uuid: String
}

// MARK: - Metadata

struct NFTTrait: Codable, Hashable {
    let name: String?
    let value: String?
    let displayType: String?
//    let rarity:

    enum CodingKeys: String, CodingKey {
        case name
        case value
        case displayType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String?.self, forKey: .name)
        displayType = try container.decode(String?.self, forKey: .displayType)
        do {
            value = try String(container.decode(Int.self, forKey: .value))
        } catch DecodingError.typeMismatch {
            do {
                value = try String(container.decode(Bool.self, forKey: .value))
            } catch DecodingError.typeMismatch {
                value = try container.decode(String?.self, forKey: .value)
            } catch {
                value = ""
            }
        } catch {
            value = ""
        }
    }
}
