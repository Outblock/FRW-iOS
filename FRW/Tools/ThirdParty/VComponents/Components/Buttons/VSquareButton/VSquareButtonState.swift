//
//  VSquareButtonState.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 19.12.20.
//

import SwiftUI

// MARK: - VSquareButtonState

/// Enum that describes state, such as `enabled` or `disabled`.
public enum VSquareButtonState: Int, CaseIterable {
    // MARK: Cases

    /// Enabled.
    case enabled

    /// Disabled.
    case disabled

    // MARK: Lifecycle

    // MARK: Initializers

    init(internalState: VSquareButtonInternalState) {
        switch internalState {
        case .enabled: self = .enabled
        case .pressed: self = .enabled
        case .disabled: self = .disabled
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

// MARK: - VSquareButtonInternalState

enum VSquareButtonInternalState {
    // MARK: Cases

    case enabled
    case pressed
    case disabled

    // MARK: Lifecycle

    // MARK: Initializers

    init(state: VSquareButtonState, isPressed: Bool) {
        switch (state, isPressed) {
        case (.enabled, false): self = .enabled
        case (.enabled, true): self = .pressed
        case (.disabled, _): self = .disabled
        }
    }

    // MARK: Internal

    // MARK: Properties

    var isEnabled: Bool {
        switch self {
        case .enabled: return true
        case .pressed: return true
        case .disabled: return false
        }
    }

    static func `default`(state: VSquareButtonState) -> Self {
        .init(state: state, isPressed: false)
    }
}

// MARK: - Mapping

extension StateColors_EPD {
    func `for`(_ state: VSquareButtonInternalState) -> Color {
        switch state {
        case .enabled: return enabled
        case .pressed: return pressed
        case .disabled: return disabled
        }
    }
}

extension StateOpacities_PD {
    func `for`(_ state: VSquareButtonInternalState) -> Double {
        switch state {
        case .enabled: return 1
        case .pressed: return pressedOpacity
        case .disabled: return disabledOpacity
        }
    }
}
