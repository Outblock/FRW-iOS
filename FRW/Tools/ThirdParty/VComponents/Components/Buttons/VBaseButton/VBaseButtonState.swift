//
//  VBaseButtonState.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/19/21.
//

import Foundation

// MARK: - V Base Button State

/// Enum that describes state, such as `enabled` or `disabled`.
public enum VBaseButtonState: Int, CaseIterable {
    // MARK: Cases

    /// Enabled.
    case enabled

    /// Disabled.
    case disabled

    // MARK: Lifecycle

    // MARK: Initializers

    init(isEnabled: Bool) {
        switch isEnabled {
        case false: self = .disabled
        case true: self = .enabled
        }
    }

    // MARK: Public

    // MARK: Properties

    /// Indicates if state is enabled.
    public var isEnabled: Bool {
        switch self {
        case .enabled: return true
        case .disabled: return false
        }
    }
}
