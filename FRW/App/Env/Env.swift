//
//  Env.swift
//  Flow Wallet
//
//  Created by Hao Fu on 29/9/2022.
//

import Foundation

// MARK: - ConfigKey

enum ConfigKey: String {
    case lilico
    case lilicoWeb = "lilico-web"
    case firebaseFunction = "firebase-function"
}

// MARK: - Config

enum Config {
    static func get(_ key: ConfigKey) -> String {
        let path = Bundle.main.path(forResource: "config", ofType: "plist")!
        let dic = NSDictionary(contentsOfFile: path) as! [String: Any]
        return dic[key.rawValue] as! String
    }

    static func get(_ key: ConfigKey) -> URL {
        let value: String = get(key)
        return URL(string: value)!
    }
}
