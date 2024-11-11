//
//  DebugViewModel.swift
//
//
//  Created by Jin Kim on 6/13/22.
//

import UIKit

open class DebugViewModel {
    private static var formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter
    }()

    public let name: String
    public let detail: String

    var showDetails: Bool = false

    public init(
        name: String, prefix: String = "", detail: String
    ) {
        let timestamp = Date()
        self.name = "[\(DebugViewModel.formatter.string(from: timestamp))\(prefix.isEmpty ? "" : " \(prefix)")] \(name)"
        self.detail = detail
    }
}
