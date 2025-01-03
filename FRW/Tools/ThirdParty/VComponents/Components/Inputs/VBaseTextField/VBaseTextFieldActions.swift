//
//  VBaseTextFieldActions.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/20/21.
//

import Foundation

// MARK: - V Base Text Field Actions

/// Enum that represents action performed when pressing `return` button.
public enum VBaseTextFieldReturnButtonAction {
    // MARK: Cases

    /// Returns and resigns responder.
    case `return`

    /// Custom action.
    case custom(_ action: () -> Void)

    /// Returns and resigns responder, and custom action.
    case returnAndCustom(_ action: () -> Void)

    // MARK: Public

    // MARK: Initailizers

    /// Default value. Set to `return`.
    public static var `default`: Self { .return }
}
