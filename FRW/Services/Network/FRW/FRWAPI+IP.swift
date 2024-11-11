//
//  FRWAPI+IP.swift
//  FRW
//
//  Created by cat on 2023/10/26.
//

import Foundation
import Moya

// MARK: - FRWAPI.IP

extension FRWAPI {
    enum IP {
        case info
    }
}

// MARK: - FRWAPI.IP + TargetType, AccessTokenAuthorizable

extension FRWAPI.IP: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        .bearer
    }

    var baseURL: URL {
        Config.get(.lilico)
    }

    var path: String {
        switch self {
        case .info:
            return "/v1/user/location"
        }
    }

    var method: Moya.Method {
        .get
    }

    var task: Task {
        switch self {
        case .info:
            return .requestParameters(parameters: [:], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        FRWAPI.commonHeaders
    }
}
