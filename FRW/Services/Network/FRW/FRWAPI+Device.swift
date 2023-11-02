//
//  FRWAPI+Device.swift
//  FRW
//
//  Created by cat on 2023/10/30.
//

import Foundation
import Moya

extension FRWAPI {
    enum Device {
        case list(String)
    }
}

extension FRWAPI.Device: TargetType, AccessTokenAuthorizable {
    
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var baseURL: URL {
        return Config.get(.lilico)
    }
    
    var path: String {
        switch self {
        case .list:
            return "/v1/user/device"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .list(let uuid):
            return .requestParameters(parameters: ["device_id": uuid], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return FRWAPI.commonHeaders
    }
    
}

