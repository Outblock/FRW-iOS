//
//  FlowAuditotEndpoint.swift
//  Flow Wallet
//
//  Created by Hao Fu on 14/9/2022.
//

import Foundation
import Moya

struct FlixAuditRequest: Codable {
    let cadenceBase64: String
    let network: String

    enum CodingKeys: String, CodingKey {
        case cadenceBase64 = "cadence_base64"
        case network
    }
}

enum FlixAuditEndpoint {
    case template(FlixAuditRequest)
}

extension FlixAuditEndpoint: TargetType {
    var baseURL: URL {
        return URL(string: "https://flix.flow.com")!
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
