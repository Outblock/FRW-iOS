//
//  LilicoAPI+Browser.swift
//  Lilico
//
//  Created by Selina on 2/9/2022.
//

import Foundation
import Moya

extension LilicoAPI {
    enum Browser {
        case recommend(String)
    }
}

extension LilicoAPI.Browser: TargetType {
    var baseURL: URL {
        return .init(string: "https://ac.duckduckgo.com")!
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
        case .recommend(let text):
            return .requestParameters(parameters: ["q": text, "type": "json"], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
