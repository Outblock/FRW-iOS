//
//  LilicoAPI+Utils.swift
//  Lilico
//
//  Created by Selina on 28/10/2022.
//

import Foundation
import Moya

extension LilicoAPI {
    enum Utils {
        case currencyRate(Currency)
        case retoken(String, String)
    }
}

extension LilicoAPI.Utils: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        switch self {
        case .currencyRate:
            return nil
        case .retoken:
            return .bearer
        }
    }
    
    var baseURL: URL {
        switch self {
        case .currencyRate:
            return .init(string: "https://api.exchangerate.host")!
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
            return "/convert"
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
            return nil
        case .retoken:
            return LilicoAPI.commonHeaders
        }
    }
}
