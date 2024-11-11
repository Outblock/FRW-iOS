//
//  FlowAuditotEndpoint.swift
//  Flow Wallet
//
//  Created by Hao Fu on 14/9/2022.
//

import Foundation
import Moya

// MARK: - FlixAuditRequest

struct FlixAuditRequest: Codable {
    enum CodingKeys: String, CodingKey {
        case cadenceBase64 = "cadence_base64"
        case network
    }

    let cadenceBase64: String
    let network: String
}

// MARK: - FlixAuditEndpoint

enum FlixAuditEndpoint {
    case template(FlixAuditRequest)
}

// MARK: TargetType

extension FlixAuditEndpoint: TargetType {
    var baseURL: URL {
        URL(string: "https://flix.flow.com")!
    }

    var path: String {
        switch self {
        case .template:
            return "/v1/templates/search"
        }
    }

    var method: Moya.Method {
        .post
    }

    var task: Task {
        switch self {
        case let .template(request):
            return .requestJSONEncodable(request)
        }
    }

    var headers: [String: String]? {
        nil
    }
}
