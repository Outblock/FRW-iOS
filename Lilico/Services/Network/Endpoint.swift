//
//  Endpoint.swift
//  Flow Reference Wallet-lite
//
//  Created by Hao Fu on 28/11/21.
//

import Foundation

enum HTTPMethod {
    case get
    case post
}

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameter: [String: String]? { get }
}

extension Endpoint {
    var headers: [String: String]? { nil }

    var parameter: [String: String]? { nil }
}
