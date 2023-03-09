//
//  LilicoWebEndpoint.swift
//  Lilico
//
//  Created by Hao Fu on 29/9/2022.
//

import Foundation
import Moya

enum LilicoWebEndpoint {
    case txTemplate(TxTemplateRequest)
    case swapEstimate(SwapEstimateRequest)
}

extension LilicoWebEndpoint: TargetType {
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var baseURL: URL {
        return URL(string: "https://lilico.app/api/")!
    }

    var path: String {
        switch self {
        case .txTemplate:
            return "template"
        case .swapEstimate:
            return "swap/v1/\(LocalUserDefaults.shared.flowNetwork.rawValue)/estimate"
        }
    }

    var method: Moya.Method {
        switch self {
        case .txTemplate:
            return .post
        case .swapEstimate:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .txTemplate(request):
            return .requestJSONEncodable(request)
        case .swapEstimate(let request):
            return .requestParameters(parameters: request.dictionary ?? [:], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        return LilicoAPI.commonHeaders
    }
}
