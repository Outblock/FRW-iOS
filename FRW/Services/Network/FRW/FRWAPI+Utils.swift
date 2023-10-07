//
//  Flow Reference WalletAPI+Utils.swift
//  Flow Reference Wallet
//
//  Created by Selina on 28/10/2022.
//

import Foundation
import Moya

extension FRWAPI {
    enum Utils {
        case currencyRate(Currency)
        case retoken(String, String)
    }
}

extension FRWAPI.Utils: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        switch self {
        case .currencyRate:
            return .bearer
        case .retoken:
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
            
        }
    }
    
    var path: String {
        switch self {
        case .currencyRate:
            return "/v1/crypto/exchange"
        case .retoken:
            return "/retoken"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .currencyRate:
            return .get
        case .retoken:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .currencyRate(let toCurrency):
            return .requestParameters(parameters: ["from": "USD", "to": toCurrency.rawValue], encoding: URLEncoding.queryString)
        case .retoken(let token, let address):
            return .requestJSONEncodable(["token": token, "address": address])
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .currencyRate:
            return FRWAPI.commonHeaders
        case .retoken:
            return FRWAPI.commonHeaders
        }
    }
}
