//
//  GithubEndpoint.swift
//  Flow Wallet
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation
import Moya

enum GithubEndpoint {
    case collections
    case ftTokenList
    case EVMNFTList
}

extension GithubEndpoint: TargetType {
    var baseURL: URL {
        return URL(string: "https://raw.githubusercontent.com")!
    }

    var path: String {
        switch self {
        case .collections:
            return "/Outblock/Assets/main/nft/nft.json"
        case .ftTokenList:
            switch LocalUserDefaults.shared.flowNetwork {
            case .testnet:
                return "/Outblock/token-list-jsons/outblock/jsons/testnet/flow/reviewers/0xa51d7fe9e0080662.json"
            case .mainnet:
                return "/Outblock/token-list-jsons/outblock/jsons/mainnet/flow/reviewers/0xa2de93114bae3e73.json"
            case .previewnet:
                return "/Outblock/token-list-jsons/outblock/jsons/previewnet/flow/default.json"
            }
        case .EVMNFTList:
            switch LocalUserDefaults.shared.flowNetwork {
            case .testnet:
                return "/Outblock/token-list-jsons/outblock/jsons/testnet/flow/nfts.json"
            case .mainnet:
                return "/Outblock/token-list-jsons/outblock/jsons/mainnet/flow/nfts.json"
            case .previewnet:
                return "/Outblock/token-list-jsons/outblock/jsons/previewnet/flow/nfts.json"
            }
        }
    }

    var method: Moya.Method {
        .get
    }

    var task: Task {
        switch self {
        case .collections, .ftTokenList, .EVMNFTList:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        nil
    }
}
