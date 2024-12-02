//
//  Flow WalletAPI+Profile.swift
//  Flow Wallet
//
//  Created by Selina on 14/6/2022.
//

import Foundation
import Moya

// MARK: - FRWAPI.Profile

extension FRWAPI {
    enum Profile {
        case updateInfo(UserInfoUpdateRequest)
        case updatePrivate(Bool)
    }
}

// MARK: - FRWAPI.Profile + TargetType, AccessTokenAuthorizable

extension FRWAPI.Profile: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        .bearer
    }

    var baseURL: URL {
        Config.get(.lilico)
    }

    var path: String {
        switch self {
        case .updateInfo:
            return "/v1/profile"
        case .updatePrivate:
            return "/v1/profile/preference"
        }
    }

    var method: Moya.Method {
        switch self {
        case .updateInfo, .updatePrivate:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .updateInfo(request):
            return .requestCustomJSONEncodable(request, encoder: FRWAPI.jsonEncoder)
        case let .updatePrivate(isPrivate):
            let raw = isPrivate ? 2 : 1
            return .requestJSONEncodable(["private": raw])
        }
    }

    var headers: [String: String]? {
        FRWAPI.commonHeaders
    }
}
