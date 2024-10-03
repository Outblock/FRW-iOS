//
//  Flow WalletAPI+Utils.swift
//  Flow Wallet
//
//  Created by Selina on 28/10/2022.
//

import Foundation
import Moya

extension FRWAPI {
    enum Utils {
        case currencyRate(Currency)
        case retoken(String, String)
        case flowAddress(String)
    }
}

extension FRWAPI.Utils: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        switch self {
        case .currencyRate:
            return .bearer
        case .retoken:
            return .bearer
        case .flowAddress:
            return .bearer
        }
    }

    var baseURL: URL {
        switch self {
        case .currencyRate:
            return Config.get(.lilico)
        case .retoken:
            #if LILICOPROD
                return .init(string: "https://scanner.lilico.app")!
            #else
                return .init(string: "https://dev-scanner.lilico.app")!
            #endif
        case .flowAddress:
            return .init(string: "https://production.key-indexer.flow.com/")!
        }
    }

    var path: String {
        switch self {
        case .currencyRate:
            return "/v1/crypto/exchange"
        case .retoken:
            return "/retoken"
        case let .flowAddress(publicKey):
            let result = publicKey.stripHexPrefix()
            return "/key/\(result)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .currencyRate, .flowAddress:
            return .get
        case .retoken:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .currencyRate(toCurrency):
            return .requestParameters(parameters: ["from": "USD", "to": toCurrency.rawValue], encoding: URLEncoding.queryString)
        case let .retoken(token, address):
            return .requestJSONEncodable(["token": token, "address": address])
        case .flowAddress:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        case .currencyRate:
            return FRWAPI.commonHeaders
        case .retoken:
            return FRWAPI.commonHeaders
        case .flowAddress:
            return FRWAPI.commonHeaders
        }
    }
}
