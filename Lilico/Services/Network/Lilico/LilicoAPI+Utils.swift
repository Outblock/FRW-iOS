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
    }
}

extension LilicoAPI.Utils: TargetType {
    var baseURL: URL {
        return .init(string: "https://api.exchangerate.host")!
    }
    
    var path: String {
        switch self {
        case .currencyRate:
            return "/convert"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .currencyRate:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .currencyRate(let toCurrency):
            return .requestParameters(parameters: ["from": "USD", "to": toCurrency.rawValue], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
