//
//  DerivedButtonType.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 2/7/21.
//

import SwiftUI

// MARK: - Derived Button Type

enum DerivedButtonType {
    case primary(model: VPrimaryButtonModel)
    case secondary(model: VSecondaryButtonModel)
    case square(model: VSquareButtonModel)
    case plain(model: VPlainButtonModel)
    case custom
}

// MARK: - Derived Button Preset

/// Enum that represents button preset, such as `primary`, `secondary`, `square`, or `plain`.
public enum DerivedButtonPreset {
    // MARK: Cases

    /// Primary button.
    case primary(model: VPrimaryButtonModel = .init())

    /// Secondary button.
    case secondary(model: VSecondaryButtonModel = .init())

    /// Square button.
    case square(model: VSquareButtonModel = .init())

    /// Plain button.
    case plain(model: VPlainButtonModel = .init())

    // MARK: Properties

    var buttonType: DerivedButtonType {
        switch self {
        case let .primary(model): return .primary(model: model)
        case let .secondary(model): return .secondary(model: model)
        case let .square(model): return .square(model: model)
        case let .plain(model): return .plain(model: model)
        }
    }

    func text(from title: String, isEnabled: Bool) -> VText {
        let color: Color = {
            switch self {
            case let .primary(model): return model.colors.textContent.for(isEnabled ? VPrimaryButtonInternalState.enabled : .disabled)
            case let .secondary(model): return model.colors.textContent.for(isEnabled ? VSecondaryButtonInternalState.enabled : .disabled)
            case let .square(model): return model.colors.textContent.for(isEnabled ? VSquareButtonInternalState.enabled : .disabled)
            case let .plain(model): return model.colors.textContent.for(isEnabled ? VPlainButtonInternalState.enabled : .disabled)
            }
        }()

        let font: Font = {
            switch self {
            case let .primary(model): return model.fonts.title
            case let .secondary(model): return model.fonts.title
            case let .square(model): return model.fonts.title
            case let .plain(model): return model.fonts.title
            }
        }()

        return .init(type: .oneLine, font: font, color: color, title: title)
    }
}
