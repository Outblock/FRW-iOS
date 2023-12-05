//
//  Flow Reference WalletAPI+Account.swift
//  Flow Reference Wallet
//
//  Created by Hao Fu on 19/5/2022.
//

import Foundation
import Moya

extension FRWAPI {
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
        case keys
        case devices(String)
        case syncDevice(SyncInfo.DeviceInfo)
    }
}

extension FRWAPI.User: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }

    var baseURL: URL {
        return Config.get(.lilico)
    }

    var path: String {
        switch self {
        case .login:
            return "/v3/login"
        case .checkUsername:
            return "/v1/user/check"
        case .register:
            return "/v3/register"
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
        case .keys:
            return "/v1/user/keys"
        case .devices:
            return "/v1/user/device"
        case .syncDevice:
            return "/v3/sync"
        }
    }

    var method: Moya.Method {
        switch self {
        case .checkUsername, .userInfo, .userWallet, .search, .keys, .devices:
            return .get
        case .login, .register, .userAddress, .manualCheck, .sandboxnet, .syncDevice:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .userAddress, .userInfo, .userWallet, .manualCheck, .sandboxnet,.keys:
            return .requestPlain
        case let .checkUsername(username):
            return .requestParameters(parameters: ["username": username], encoding: URLEncoding.queryString)
        case let .register(request):
            return .requestCustomJSONEncodable(request, encoder: FRWAPI.jsonEncoder)
        case let .login(request):
            return .requestCustomJSONEncodable(request, encoder: FRWAPI.jsonEncoder)
        case let .search(keyword):
            return .requestParameters(parameters: ["keyword": keyword], encoding: URLEncoding.queryString)
        case let .devices(uuid):
            return .requestParameters(parameters: ["device_id": uuid], encoding: URLEncoding.queryString)
        case let .syncDevice(request):
            return .requestCustomJSONEncodable(request, encoder: FRWAPI.jsonEncoder)
        }
    }

    var headers: [String: String]? {
        var headers = FRWAPI.commonHeaders
        switch self {
        case .sandboxnet:
            headers["Network"] = "sandboxnet"
        default:
            break
        }
        
        return headers
    }
}
