//
//  VTextFieldType.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/20/21.
//

import Foundation

// MARK: - V Text Field Type

/// Enum that describes type, such as `standard`, `secure`, or `search`.
public enum VTextFieldType: Int, CaseIterable {
    // MARK: Cases

    /// Standard textfield.
    case standard

    /// Secure textfield.
    ///
    /// Visibility icon is present, and securities, such as copying is enabled.
    case secure

    /// Search textfield.
    ///
    /// Magnification icon is present.
    case search

    case userName

    // MARK: Public

    // MARK: Initailizers

    /// Default value. Set to `standard`.
    public static var `default`: Self { .standard }

    // MARK: Internal

    // MARK: Properties

    var isStandard: Bool {
        self == .standard
    }

    var isSecure: Bool {
        self == .secure
    }

    var isSearch: Bool {
        self == .search
    }

    var isUserName: Bool {
        self == .userName
    }
}
