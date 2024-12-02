//
//  VRadioButtonState.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/19/21.
//

import SwiftUI

// MARK: - VRadioButtonState

/// Enum that describes state, such as `off`, `on`, or `disabled`.
public enum VRadioButtonState: Int, CaseIterable {
    // MARK: Cases

    /// Off.
    case off

    /// On.
    case on

    /// Disabled.
    case disabled

    // MARK: Lifecycle

    // MARK: Initializers

    init(internalState: VRadioButtonInternalState) {
        switch internalState {
        case .off, .pressedOff: self = .off
        case .on, .pressedOn: self = .on
        case .disabled: self = .disabled
        }
    }

    // MARK: Public

    // MARK: Properties

    /// Indicates if state is enabled.
    public var isEnabled: Bool {
        switch self {
        case .off: return true
        case .on: return true
        case .disabled: return false
        }
    }

    /// Indicates if state is on.
    public var isOn: Bool {
        switch self {
        case .off: return false
        case .on: return true
        case .disabled: return false
        }
    }

    // MARK: Next State

    /// Goes to the next state.
    public mutating func setNextState() {
        switch self {
        case .off: self = .on
        case .on: self = .on
        case .disabled: break
        }
    }
}

// MARK: - VRadioButtonInternalState

enum VRadioButtonInternalState {
    // MARK: Cases

    case off
    case on
    case pressedOff
    case pressedOn
    case disabled

    // MARK: Lifecycle

    // MARK: Initializers

    init(state: VRadioButtonState, isPressed: Bool) {
        switch (state, isPressed) {
        case (.off, false): self = .off
        case (.off, true): self = .pressedOff
        case (.on, false): self = .on
        case (.on, true): self = .pressedOn
        case (.disabled, _): self = .disabled
        }
    }

    init(bool state: Bool, isPressed: Bool) {
        switch (state, isPressed) {
        case (false, false): self = .off
        case (false, true): self = .pressedOff
        case (true, false): self = .on
        case (true, true): self = .pressedOn
        }
    }

    // MARK: Internal

    // MARK: Properties

    var isEnabled: Bool {
        switch self {
        case .off: return true
        case .on: return true
        case .pressedOff: return true
        case .pressedOn: return true
        case .disabled: return false
        }
    }

    static func `default`(state: VRadioButtonState) -> Self {
        .init(state: state, isPressed: false)
    }

    // MARK: Next State

    mutating func setNextState() {
        switch self {
        case .off, .pressedOff: self = .on
        case .on, .pressedOn: self = .on
        case .disabled: break
        }
    }
}

// MARK: - Mapping

extension StateColors_OOD {
    func `for`(_ state: VRadioButtonInternalState) -> Color {
        switch state {
        case .off: return off
        case .on: return on
        case .pressedOff: return pressedOff
        case .pressedOn: return pressedOn
        case .disabled: return disabled
        }
    }
}

extension StateOpacities_PD {
    func `for`(_ state: VRadioButtonInternalState) -> Double {
        switch state {
        case .off: return 1
        case .on: return 1
        case .pressedOff: return pressedOpacity
        case .pressedOn: return pressedOpacity
        case .disabled: return disabledOpacity
        }
    }
}

// MARK: - Helpers

extension Binding where Value == VRadioButtonState {
    /// Initializes state with bool.
    public init(bool: Binding<Bool>) {
        self.init(
            get: { bool.wrappedValue ? .on : .off },
            set: { bool.wrappedValue = $0.isOn }
        )
    }
}
