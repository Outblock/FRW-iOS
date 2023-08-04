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
    }
}

extension LilicoAPI.ChildAccount: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }

    var baseURL: URL {
        return Config.get(.lilico)
    }

    var path: String {
        switch self {
        case .collection:
            let path =  LocalUserDefaults.shared.flowNetwork == .testnet ? "/api/hc/testnet/nftIdWithDisplay" : "/api/hc/mainnet/nftIdWithDisplay"
            return path
        }
        
    }

    var method: Moya.Method {
        switch self {
        case .collection:
                return .get
        }
    }

    var task: Task {
        switch self {
            case let .collection(address, childAddress):
                return .requestParameters(parameters: ["address": address,"childAddress":childAddress], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        return LilicoAPI.commonHeaders
    }
}
