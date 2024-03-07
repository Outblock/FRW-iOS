//
//  FRWAPI+Cadence.swift
//  FRW
//
//  Created by cat on 2024/3/6.
//

import Foundation

import Foundation
import Moya

extension FRWAPI {
    enum Cadence {
        case list
    }
}

extension FRWAPI.Cadence: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var baseURL: URL {
        switch self {
        case .list:
#if LILICOPROD
            return .init(string: "https://us-central1-lilico-dev.cloudfunctions.net")!
#else
            return .init(string: "https://us-central1-lilico-dev.cloudfunctions.net")!
#endif
        }
    }
    
    var path: String {
        switch self {
        case .list:
            return "/fetchScripts"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .list:
            return .requestParameters(parameters: [:], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String: String]? {
        return FRWAPI.commonHeaders
    }
}
