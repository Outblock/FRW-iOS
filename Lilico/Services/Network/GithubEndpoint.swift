//
//  GithubEndpoint.swift
//  Lilico
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation
import Moya

enum GithubEndpoint {
    case collections
}

extension GithubEndpoint: TargetType {
    var baseURL: URL {
        return URL(string: "https://raw.githubusercontent.com")!
    }

    var path: String {
        switch self {
        case .collections:
            return "/Outblock/Assets/main/nft/nft.json"
        }
    }

    var method: Moya.Method {
        .get
    }

    var task: Task {
        switch self {
        case .collections:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        nil
    }
}
