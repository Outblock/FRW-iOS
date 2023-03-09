//
//  LilicoAPI.swift
//  Lilico
//
//  Created by Hao Fu on 29/12/21.
//

import Foundation

enum LilicoAPI {
    static var jsonEncoder: JSONEncoder {
        let coder = JSONEncoder()
        coder.keyEncodingStrategy = .convertToSnakeCase
        return coder
    }

    static var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    static var commonHeaders: [String: String] {
        let network = LocalUserDefaults.shared.flowNetwork.rawValue
        return ["Network": network]
    }
}
