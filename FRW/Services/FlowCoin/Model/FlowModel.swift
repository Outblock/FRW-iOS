//
//  FlowModel.swift
//  Flow Reference Wallet
//
//  Created by cat on 2023/8/3.
//

import Foundation

struct FlowModel {
    
}

protocol MetadataViewsFile: Codable {
    func uri() -> String
}

//MARK: struct MetadataViews and substruct
extension FlowModel {
    
    struct MetadataViews {
        struct Media<T:MetadataViewsFile>: Codable {
            let file: T
            let mediaType: String
        }
        
        struct HTTPFile: MetadataViewsFile, Codable {
            let url: String
            init(url: String) {
                self.url = url
            }
            
            func uri() -> String {
                return self.url
            }
        }
        
        struct NFTCollectionDisplay: Codable {
            let name: String
            let squareImage: MetadataViews.Media<HTTPFile>
        }
    }
    
}

// MARK: custom struct for convenient base on flow
// https://testnet.contractbrowser.com/A.631e88ae7f1d7c20.MetadataViews
extension FlowModel {
    struct CollectionDislay: Codable {
        var name: String
        var squareImage: String
        var mediaType: String
    }
    
    struct NFTCollection: Codable, Mockable {
        static func mock() -> FlowModel.NFTCollection {
            return FlowModel.NFTCollection(id: "", path: "", display: nil, idList: [])
        }
        
        var id: String
        var path: String
        var display: CollectionDislay?
        let idList: [UInt64]
    }
    
    struct NFTInfo: Codable {
        let id: String
        let name: String
        let description: String
        let thumbnail: String
    }
    
    struct TokenInfo: Codable, Mockable {
        var id: String
        let balance: UInt64
        
        static func mock() -> FlowModel.TokenInfo {
            return TokenInfo(id: " ", balance: 0)
        }
    }
    
    struct NFTResponse: Codable {
        let collection: FlowModel.NFTCollection
        let nfts: [NFTInfo]
    }
}
