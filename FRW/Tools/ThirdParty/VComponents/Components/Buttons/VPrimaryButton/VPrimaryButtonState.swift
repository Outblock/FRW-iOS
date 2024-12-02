//
//  VPrimaryButtonState.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 19.12.20.
//

import SwiftUI

// MARK: - VPrimaryButtonState

/// Enum that describes state, such as `enabled`, `disabled`, or `loading`.
public enum VPrimaryButtonState: Int, CaseIterable {
    // MARK: Cases

    /// Enabled.
    case enabled

    /// Disabled.
    case disabled

    /// Loading.
    ///
    /// Unique state during which spinner appears.
    case loading

    // MARK: Lifecycle

    // MARK: Initializers

    init(internalState: VPrimaryButtonInternalState) {
        switch internalState {
        case .enabled: self = .enabled
        case .pressed: self = .enabled
        case .disabled: self = .disabled
        case .loading: self = .loading
        }
    }

    // MARK: Public

    // MARK: Properties

    /// Indicates if state is enabled.
    public var isEnabled: Bool {
        switch self {
        case .enabled: return true
        case .disabled: return false
        case .loading: return false
        }
    }
}

// MARK: - VPrimaryButtonInternalState

enum VPrimaryButtonInternalState {
    // MARK: Cases

    case enabled
    case pressed
    case disabled
    case loading

    // MARK: Lifecycle

    // MARK: Initializers

    init(state: VPrimaryButtonState, isPressed: Bool) {
        switch (state, isPressed) {
        case (.enabled, false): self = .enabled
        case (.enabled, true): self = .pressed
        case (.disabled, _): self = .disabled
        case (.loading, _): self = .loading
        }
    }

    // MARK: Internal

    // MARK: Properties

    var isEnabled: Bool {
        switch self {
        case .enabled: return true
        case .pressed: return true
        case .disabled: return false
        case .loading: return false
        }
    }

    var isLoading: Bool {
        switch self {
        case .enabled: return false
        case .pressed: return false
        case .disabled: return false
        case .loading: return true
        }
    }

    static func `default`(state: VPrimaryButtonState) -> Self {
        .init(state: state, isPressed: false)
    }
}

// MARK: - Mapping

extension StateColors_EPLD {
    func `for`(_ state: VPrimaryButtonInternalState) -> Color {
        switch state {
        case .enabled: return enabled
        case .pressed: return pressed
        case .disabled: return disabled
        case .loading: return loading
        }
    }
}

extension StateOpacities_PD {
    func `for`(_ state: VPrimaryButtonInternalState) -> Double {
        switch state {
        case .enabled: return 1
        case .pressed: return pressedOpacity
        case .disabled: return disabledOpacity
        case .loading: return disabledOpacity
        }
    }
}
