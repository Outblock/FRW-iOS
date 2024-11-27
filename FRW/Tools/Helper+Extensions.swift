//
//  Helper+Extensions.swift
//  FRW
//
//  Created by Antonio Bello on 11/25/24.
//

import Foundation

extension String? {
    var isNotNullNorEmpty: Bool {
        // An optional bool is a 3-state variable: nil, false, true, so this expression evaluates to true only if self is
        self?.isEmpty == false
    }
}

extension URL? {
    var isNotNullNorEmpty: Bool {
        self?.absoluteString.isEmpty == false
    }
}
