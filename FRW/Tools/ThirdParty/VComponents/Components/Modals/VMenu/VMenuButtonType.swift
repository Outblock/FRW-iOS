//
//  VMenuPreset.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/28/21.
//

import SwiftUI

// MARK: - V Menu  Button Type

typealias VMenuButtonType = DerivedButtonType

// MARK: - V Menu  Button Preset

/// Enum that describes menu button preset, such as `primary`, `secondary`, `square`, or `plain`.
///
/// Custom type can be used via inits that do not take preset as a parameter.
public typealias VMenuButtonPreset = DerivedButtonPreset

// MARK: - Button

extension VMenuButtonType {
    @ViewBuilder static func menuButton<Content>(
        buttonType: VMenuButtonType,
        isEnabled: Bool,
        @ViewBuilder label: @escaping () -> Content
    ) -> some View
        where Content: View
    {
        switch buttonType {
        case let .primary(model):
            VPrimaryButton(
                model: model,
                state: isEnabled ? .enabled : .disabled,
                action: {},
                content: label
            )

        case let .secondary(model):
            VSecondaryButton(
                model: model,
                state: isEnabled ? .enabled : .disabled,
                action: {},
                content: label
            )

        case let .square(model):
            VSquareButton(
                model: model,
                state: isEnabled ? .enabled : .disabled,
                action: {},
                content: label
            )

        case let .plain(model):
            VPlainButton(
                model: model,
                state: isEnabled ? .enabled : .disabled,
                action: {},
                content: label
            )

        case .custom:
            label()
        }
    }
}
