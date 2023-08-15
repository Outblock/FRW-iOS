//
//  LilicoAPI+ChildAccount.swift
//  Lilico
//
//  Created by cat on 2023/8/2.
//

import Foundation
import Moya

extension LilicoAPI {
    enum ChildAccount {
        case collection(String, String)
        case collectionInfo(String, String)
        // Address, path, offset, limit
        case nftList(String, String,Int,Int)
    }
}

extension LilicoAPI.ChildAccount: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }

    var baseURL: URL {
        #if DEBUG
        return URL(string: "https://a5e5-220-233-193-77.ngrok-free.app")!
        #endif
        return Config.get(.lilico)
    }

    var path: String {
        var thePath = ""
        let network = LocalUserDefaults.shared.flowNetwork == .testnet ? "testnet" : "mainnet"
        switch self {
            case .collection:
                thePath = "/api/hc/{{network}}/nftIdWithDisplay"
            case .collectionInfo:
                thePath = "/api/storage/{{network}}/nft/collection"
            case .nftList:
                thePath = "/api/storage/{{network}}/nft"
        }
        
        thePath = thePath.replace("{{network}}", with: network)
        return thePath
    }
    

    var method: Moya.Method {
        switch self {
            default:
                return .get
        }
    }

    var task: Task {
        switch self {
            case let .collection(address, childAddress):
                return .requestParameters(parameters: ["address": address,"childAddress":childAddress], encoding: URLEncoding.queryString)
            case let .collectionInfo(addr, path):
                return .requestParameters(parameters: ["address": addr, "path": path], encoding: URLEncoding.queryString)
            case let .nftList(addr, path, offset, limit):
                return .requestParameters(parameters: ["address": addr, "path": path, "offset": offset, "limit": limit], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        return LilicoAPI.commonHeaders
    }
}
