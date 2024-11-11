//
//  Flow WalletAPI+Browser.swift
//  Flow Wallet
//
//  Created by Selina on 2/9/2022.
//

import Foundation
import Moya

// MARK: - FRWAPI.Browser

extension FRWAPI {
    enum Browser {
        case recommend(String)
    }
}

// MARK: - FRWAPI.Browser + TargetType

extension FRWAPI.Browser: TargetType {
    var baseURL: URL {
        .init(string: "https://ac.duckduckgo.com")!
    }

    var path: String {
        switch self {
        case .recommend:
            return "/ac"
        }
    }

    var method: Moya.Method {
        switch self {
        case .recommend:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .recommend(text):
            return .requestParameters(
                parameters: ["q": text, "type": "json"],
                encoding: URLEncoding.queryString
            )
        }
    }

    var headers: [String: String]? {
        nil
    }
}
