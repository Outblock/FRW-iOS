//
//  FlowModel.swift
//  Lilico
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
        let name: String
        let squareImage: String
        let mediaType: String
    }
    
    struct NFTCollection: Codable, Mockable {
        static func mock() -> FlowModel.NFTCollection {
            return FlowModel.NFTCollection(id: "", display: nil, idList: [])
        }
        
        let id: String
        let display: CollectionDislay?
        let idList: [UInt64]
        
    }
    
    struct TokenInfo: Codable, Mockable {
        let id: String
        let balance: UInt64
        
        static func mock() -> FlowModel.TokenInfo {
            return TokenInfo(id: " ", balance: 0)
        }
    }
}
