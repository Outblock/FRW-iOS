//
//  VSliderState.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 19.12.20.
//

import SwiftUI

// MARK: - VSliderState

/// Enum that describes state, such as `enabled` or `disabled`.
public enum VSliderState: Int, CaseIterable {
    // MARK: Cases

    /// Enabled.
    case enabled

    /// Disabled.
    case disabled

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

// MARK: - Mapping

extension StateColors_ED {
    func `for`(_ state: VSliderState) -> Color {
        switch state {
        case .enabled: return enabled
        case .disabled: return disabled
        }
    }
}
