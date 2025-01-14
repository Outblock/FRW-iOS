//
//  KeyValueModel.swift
//  FRW
//
//  Created by cat on 1/8/25.
//

import Foundation

struct FormItem: Codable {
    let value: JSONValue
    let isCheck: Bool

    init(value: JSONValue, isCheck: Bool = false) {
        self.value = value
        self.isCheck = isCheck
    }
}

