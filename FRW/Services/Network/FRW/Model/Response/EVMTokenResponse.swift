//
//  EVMResponse.swift
//  FRW
//
//  Created by cat on 2024/4/29.
//

import Foundation
import web3swift
import Web3Core
import BigInt

struct EVMTokenResponse: Codable {
    let chainId: Int
    let address: String
    let symbol: String
    let name: String
    let decimals: Int
    let logoURI: String
    let balance: String?
    let flowIdentifier: String?
    

    func toTokenModel() -> TokenModel {
        
        let model = TokenModel(name: name,
                               address: FlowNetworkModel(mainnet: nil, testnet: nil, crescendo: nil, previewnet: address),
                               contractName: "",
                               storagePath: FlowTokenStoragePath(balance: "", vault: "", receiver: ""),
                               decimal: decimals,
                               icon: .init(string: logoURI),
                               symbol: symbol,
                               website: nil, evmAddress: nil, flowIdentifier: flowIdentifier)
        return model
    }
    
    var flowBalance: Double {
        guard let bal = balance, let value = BigUInt(bal) else {
            return 0
        }
        return Utilities.formatToPrecision(value, formattingDecimals: decimals).doubleValue
    }
}

struct EVMCollection: Codable {
    let chainId: Int
    let address: String
    let symbol: String
    let name: String
    let tokenURI: String
    let logoURI: String
    let balance: String?
    let flowIdentifier: String?
    let nftIds: [String]
    let nfts: [EVMNFT]
    
    func toNFTCollection() -> NFTCollection {
        let contractName = flowIdentifier?.split(separator: ".")[1] ?? ""
        let contractAddress = flowIdentifier?.split(separator: ".")[2] ?? ""
        let info = NFTCollectionInfo(id: flowIdentifier ?? "", name: name, contractName: String(contractName), address: String(contractAddress), logo: logoURI, banner: nil, officialWebsite: nil, description: nil, path: ContractPath(storagePath: "", publicPath: "", publicCollectionName: nil, publicType: nil, privateType: nil), evmAddress: address, socials: nil)
        let list = nfts.map {  NFTModel($0.toNFT(), in: info) }
        let model = NFTCollection(collection: info,
                                  count: nfts.count,
                                  ids: nftIds,
                                  evmNFTs: list
        )
        return model
    }
}

struct EVMNFT: Codable {
    let id: String
    let name: String
    let thumbnail: String
    
    func toNFT() -> NFTResponse {
        NFTResponse(id: id, name: name, description: nil, thumbnail: thumbnail, externalURL: nil, contractAddress: nil, collectionID: nil, collectionName: nil, collectionDescription: nil, collectionSquareImage: nil, collectionExternalURL: nil, collectionContractName: nil, collectionBannerImage: nil, traits: nil, postMedia: NFTPostMedia(title: nil, image: thumbnail,description: nil, video: nil, isSvg: nil))
    }
}
