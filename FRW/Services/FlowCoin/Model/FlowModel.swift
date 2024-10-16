//
//  FlowModel.swift
//  Flow Wallet
//
//  Created by cat on 2023/8/3.
//

import Foundation

struct FlowModel {}

// MARK: struct MetadataViews and substruct

extension FlowModel {
    struct Media: Codable {
        struct File: Codable {
            let url: String
        }

        let file: Media.File
//        let mediaType: String
    }
}

// MARK: custom struct for convenient base on flow

// https://testnet.contractbrowser.com/A.631e88ae7f1d7c20.MetadataViews

extension FlowModel {
    struct NFTCollection: Codable, Mockable {
        struct CollectionDislay: Codable {
            var name: String
            var mediaType: FlowModel.Media?
            var squareImage: String?
        }

        static func mock() -> FlowModel.NFTCollection {
            return FlowModel.NFTCollection(id: "", path: "", display: nil, idList: [])
        }

        var id: String
        var path: String?
        var display: FlowModel.NFTCollection.CollectionDislay?
        var idList: [UInt64]
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
