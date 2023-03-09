//
//  LilicoAPI+Profile.swift
//  Lilico
//
//  Created by Selina on 14/6/2022.
//

import Foundation
import Moya

extension LilicoAPI {
    enum Profile {
        case updateInfo(UserInfoUpdateRequest)
        case updatePrivate(Bool)
    }
}

extension LilicoAPI.Profile: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }

    var baseURL: URL {
        return Config.get(.lilico)
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
            return .requestCustomJSONEncodable(request, encoder: LilicoAPI.jsonEncoder)
        case let .updatePrivate(isPrivate):
            let raw = isPrivate ? 2 : 1
            return .requestJSONEncodable(["private": raw])
        }
    }

    var headers: [String: String]? {
        return LilicoAPI.commonHeaders
    }
}
