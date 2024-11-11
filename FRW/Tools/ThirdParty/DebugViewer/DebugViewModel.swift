//
//  DebugViewModel.swift
//
//
//  Created by Jin Kim on 6/13/22.
//

import UIKit

open class DebugViewModel {
    // MARK: Lifecycle

    public init(
        name: String, prefix: String = "", detail: String
    ) {
        let timestamp = Date()
        self
            .name =
            "[\(DebugViewModel.formatter.string(from: timestamp))\(prefix.isEmpty ? "" : " \(prefix)")] \(name)"
        self.detail = detail
    }

    // MARK: Public

    public let name: String
    public let detail: String

    // MARK: Internal

    var showDetails: Bool = false

    // MARK: Private

    private static var formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter
    }()
}
