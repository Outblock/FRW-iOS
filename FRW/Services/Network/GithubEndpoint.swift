//
//  GithubEndpoint.swift
//  Flow Wallet
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation
import Moya

// MARK: - GithubEndpoint

enum GithubEndpoint {
    case collections
    case ftTokenList
    case EVMNFTList
    case EVMTokenList
}

// MARK: TargetType

extension GithubEndpoint: TargetType {
    var baseURL: URL {
        URL(string: "https://raw.githubusercontent.com")!
    }

    var path: String {
        switch self {
        case .collections:
            return "/Outblock/Assets/main/nft/nft.json"
        case .ftTokenList:
            if isDevModel {
                switch LocalUserDefaults.shared.flowNetwork {
                case .mainnet:
                    return "/Outblock/token-list-jsons/outblock/jsons/mainnet/flow/dev.json"
                case .testnet:
                    return "/Outblock/token-list-jsons/outblock/jsons/testnet/flow/dev.json"
                }
            } else {
                switch LocalUserDefaults.shared.flowNetwork {
                case .mainnet:
                    return "/Outblock/token-list-jsons/outblock/jsons/mainnet/flow/default.json"
                case .testnet:
                    return "/Outblock/token-list-jsons/outblock/jsons/testnet/flow/default.json"
                }
            }
        case .EVMNFTList:
            switch LocalUserDefaults.shared.flowNetwork {
            case .testnet:
                return "/Outblock/token-list-jsons/outblock/jsons/testnet/flow/nfts.json"
            case .mainnet:
                return "/Outblock/token-list-jsons/outblock/jsons/mainnet/flow/nfts.json"
            }
        case .EVMTokenList:
            if isDevModel {
                switch LocalUserDefaults.shared.flowNetwork {
                case .mainnet:
                    return "/Outblock/token-list-jsons/outblock/jsons/mainnet/evm/dev.json"
                default:
                    return "/Outblock/token-list-jsons/outblock/jsons/testnet/evm/dev.json"
                }
            } else {
                switch LocalUserDefaults.shared.flowNetwork {
                case .mainnet:
                    return "/Outblock/token-list-jsons/outblock/jsons/mainnet/evm/default.json"
                default:
                    return "/Outblock/token-list-jsons/outblock/jsons/testnet/evm/default.json"
                }
            }
        }
    }

    var method: Moya.Method {
        .get
    }

    var task: Task {
        switch self {
        case .collections, .ftTokenList, .EVMNFTList, .EVMTokenList:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        nil
    }
}
