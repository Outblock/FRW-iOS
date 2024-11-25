//
//  Flow WalletAPI+Flowns.swift
//  Flow Wallet
//
//  Created by Selina on 16/9/2022.
//

import Foundation
import Moya

// MARK: - FRWAPI.Flowns

extension FRWAPI {
    enum Flowns {
        case domainPrepare
        case domainSignature(SignPayerRequest)
        case queryInbox(String)
    }
}

// MARK: - FRWAPI.Flowns + TargetType, AccessTokenAuthorizable

extension FRWAPI.Flowns: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        .bearer
    }

    var baseURL: URL {
        switch self {
        case .queryInbox:
            return LocalUserDefaults.shared
                .flowNetwork == .testnet ? .init(string: "https://testnet.flowns.io")! :
                .init(string: "https://flowns.io")!
        default:
            return Config.get(.lilico)
        }
    }

    var path: String {
        switch self {
        case .domainPrepare:
            return "/v1/flowns/prepare"
        case .domainSignature:
            return "/v1/flowns/signature"
        case let .queryInbox(domain):
            return "/api/data/domain/\(domain)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .domainPrepare:
            return .get
        case .domainSignature:
            return .post
        case .queryInbox:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .domainPrepare:
            return .requestParameters(parameters: [:], encoding: URLEncoding.queryString)
        case let .domainSignature(request):
            return .requestJSONEncodable(request)
        case .queryInbox:
            return .requestParameters(parameters: [:], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        FRWAPI.commonHeaders
    }
}
