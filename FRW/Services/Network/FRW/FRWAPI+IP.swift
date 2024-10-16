//
//  FRWAPI+IP.swift
//  FRW
//
//  Created by cat on 2023/10/26.
//

import Foundation
import Moya

extension FRWAPI {
    enum IP {
        case info
    }
}

extension FRWAPI.IP: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }

    var baseURL: URL {
        return Config.get(.lilico)
    }

    var path: String {
        switch self {
        case .info:
            return "/v1/user/location"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case .info:
            return .requestParameters(parameters: [:], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        return FRWAPI.commonHeaders
    }
}
