//
//  LilicoAPI+Account.swift
//  Lilico
//
//  Created by Hao Fu on 19/5/2022.
//

import Foundation
import Moya

extension LilicoAPI {
    enum User {
        case login(LoginRequest)
        case register(RegisterRequest)
        case checkUsername(String)
        case userAddress
        case userInfo
        case userWallet
        case search(String)
        case manualCheck
        case sandboxnet
    }
}

extension LilicoAPI.User: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }

    var baseURL: URL {
        return Config.get(.lilico)
    }

    var path: String {
        switch self {
        case .login:
            return "/v2/login"
        case .checkUsername:
            return "/v1/user/check"
        case .register:
            return "/v1/register"
        case .userAddress:
            return "/v1/user/address"
        case .userInfo:
            return "/v1/user/info"
        case .userWallet:
            return "/v2/user/wallet"
        case .search:
            return "/v1/user/search"
        case .manualCheck:
            return "/v1/user/manualaddress"
        case .sandboxnet:
            return "/v1/user/address/sandboxnet"
        }
    }

    var method: Moya.Method {
        switch self {
        case .checkUsername, .userInfo, .userWallet, .search:
            return .get
        case .login, .register, .userAddress, .manualCheck, .sandboxnet:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .userAddress, .userInfo, .userWallet, .manualCheck, .sandboxnet:
            return .requestPlain
        case let .checkUsername(username):
            return .requestParameters(parameters: ["username": username], encoding: URLEncoding.queryString)
        case let .register(request):
            return .requestCustomJSONEncodable(request, encoder: LilicoAPI.jsonEncoder)
        case let .login(request):
            return .requestCustomJSONEncodable(request, encoder: LilicoAPI.jsonEncoder)
        case let .search(keyword):
            return .requestParameters(parameters: ["keyword": keyword], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        var headers = LilicoAPI.commonHeaders
        switch self {
        case .sandboxnet:
            headers["Network"] = "sandboxnet"
        default:
            break
        }
        
        return headers
    }
}
