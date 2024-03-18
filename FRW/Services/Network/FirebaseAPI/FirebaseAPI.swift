//
//  FirebaseAPI.swift
//  Flow Wallet
//
//  Created by Hao Fu on 5/9/2022.
//

import Foundation
import Moya
import Flow
import BigInt

enum FirebaseAPI {
    case signAsPayer(SignPayerRequest)
    case moonPay(MoonPayRequest)
}

extension FirebaseAPI: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        .bearer
    }

    var baseURL: URL {
        Config.get(.firebaseFunction)
    }

    var path: String {
        switch self {
        case .signAsPayer:
            return "/signAsPayer"
        case .moonPay:
            return "/moonPaySignature"
        }
    }

    var method: Moya.Method {
        switch self {
        case .moonPay, .signAsPayer:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .moonPay(request):
            return .requestJSONEncodable(request)
        case let .signAsPayer(request):
            return .requestJSONEncodable(request)
        }
    }

    var headers: [String: String]? {
        return FRWAPI.commonHeaders
    }
}
