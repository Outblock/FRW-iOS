//
//  FRWAPI+EVM.swift
//  FRW
//
//  Created by cat on 2024/4/29.
//

import Foundation
import Moya

extension FRWAPI {
    enum EVM {
        case tokenList(String)
        case nfts(String?)
    }
}

extension FRWAPI.EVM: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }

    var baseURL: URL {
        switch self {
        case .tokenList, .nfts:
            return Config.get(.lilicoWeb)
        }
    }

    var path: String {
        switch self {
        case let .tokenList(addr):
            return "v3/evm/\(addr)/fts"
        case let .nfts(addr):
            if let addr = addr {
                return "v2/evm/\(addr)/nfts"
            }
            return "v2/evm/nfts"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        let network = LocalUserDefaults.shared.flowNetwork.rawValue

        switch self {
        case .tokenList, .nfts:
            return .requestParameters(parameters: ["network": network], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        let headers = FRWAPI.commonHeaders
        return headers
    }
}
