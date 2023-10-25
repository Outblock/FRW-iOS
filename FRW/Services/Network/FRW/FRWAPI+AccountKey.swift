//
//  FRWAPI+AccountKey.swift
//  FRW
//
//  Created by cat on 2023/10/20.
//

import Foundation
import Moya

extension FRWAPI {
    enum AccountKey {
        case keys
    }
}

extension FRWAPI.AccountKey: TargetType, AccessTokenAuthorizable {
    
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var baseURL: URL {
        return Config.get(.lilico)
    }
    
    var path: String {
        switch self {
        case .keys:
            //TODO: @six path
            return ""
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .keys: //TODO: @six param
            return .requestParameters(parameters: [:], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return FRWAPI.commonHeaders
    }
    
}
