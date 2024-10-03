//
//  Flow WalletAPI+Crypto.swift
//  Flow Wallet
//
//  Created by Selina on 23/6/2022.
//

import Foundation
import Moya

extension FRWAPI {
    enum Crypto {
        case summary(CryptoSummaryRequest)
        case history(CryptoHistoryRequest)
        case prices
    }
}

extension FRWAPI.Crypto: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }

    var baseURL: URL {
        switch self {
        case .prices:
            return Config.get(.lilicoWeb)
        default:
            return Config.get(.lilico)
        }
    }

    var path: String {
        switch self {
        case .summary:
            return "/v1/crypto/summary"
        case .history:
            return "/v1/crypto/history"
        case .prices:
            return "prices"
        }
    }

    var method: Moya.Method {
        switch self {
        case .summary, .history, .prices:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .summary(request):
            return .requestParameters(parameters: request.dictionary ?? [:], encoding: URLEncoding())
        case let .history(request):
            return .requestParameters(parameters: request.dictionary ?? [:], encoding: URLEncoding())
        case .prices:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return FRWAPI.commonHeaders
    }
}
