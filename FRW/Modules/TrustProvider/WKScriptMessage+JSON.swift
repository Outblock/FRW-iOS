//
//  WKScriptMessage+JSON.swift
//  FRW
//
//  Created by cat on 2024/3/4.
//

import WebKit

extension WKScriptMessage {
    var json: [String: Any] {
        if let string = body as? String,
           let data = string.data(using: .utf8),
           let object = try? JSONSerialization.jsonObject(with: data, options: []),
           let dict = object as? [String: Any] {
            return dict
        } else if let object = body as? [String: Any] {
            return object
        }
        return [:]
    }
}
