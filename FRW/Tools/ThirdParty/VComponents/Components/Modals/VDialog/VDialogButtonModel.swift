//
//  VDialogButtonModel.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/14/21.
//

import SwiftUI

// MARK: - VDialogButtonModel

/// Enum that describes `VDialog` button model, such as `primary`, `secondary`, or `custom`.
public enum VDialogButtonModel {
    // MARK: Cases

    /// Primary button.
    case primary

    /// Secondary button.
    case secondary

    /// Custom button.
    case custom(_ model: VDialogButtonModelCustom)

    // MARK: Internal

    // MARK: Sub-Models

    var buttonSubModel: VPrimaryButtonModel {
        switch self {
        case .primary: return VDialogButtonModel.primaryButtonSubModel.primaryButtonSubModel
        case .secondary: return VDialogButtonModel.secondaryButtonSubModel.primaryButtonSubModel
        case let .custom(model): return model.primaryButtonSubModel
        }
    }

    // MARK: Private

    private static let primaryButtonSubModel: VDialogButtonModelCustom = .init(
        colors: .init(
            content: .init(
                pressedOpacity: 0.5
            ),
            text: .init(
                enabled: VDialogButtonModelCustom.primaryButtonReference.colors.textContent.enabled,
                pressed: VDialogButtonModelCustom.primaryButtonReference.colors.textContent.pressed,
                disabled: VDialogButtonModelCustom.primaryButtonReference.colors.textContent
                    .disabled
            ),
            background: .init(
                enabled: VDialogButtonModelCustom.primaryButtonReference.colors.background.enabled,
                pressed: VDialogButtonModelCustom.primaryButtonReference.colors.background.pressed,
                disabled: VDialogButtonModelCustom.primaryButtonReference.colors.background.disabled
            )
        )
    )

    private static let secondaryButtonSubModel: VDialogButtonModelCustom = .init(
        colors: .init(
            content: .init(
                pressedOpacity: 0.5
            ),
            text: .init(
                enabled: VDialogButtonModelCustom.primaryButtonReference.colors.background.enabled,
                pressed: VDialogButtonModelCustom.primaryButtonReference.colors.background.pressed,
                disabled: VDialogButtonModelCustom.primaryButtonReference.colors.background.disabled
            ),
            background: .init(
                enabled: .clear,
                pressed: .clear,
                disabled: .clear
            )
        )
    )
}

// MARK: - VDialogButtonModelCustom

/// Model that describes UI.
public struct VDialogButtonModelCustom {
    // MARK: Lifecycle

    // MARK: Initializers

    /// Initializes model with colors.
    public init(layout: Layout = .init(), colors: Colors, fonts: Fonts = .init()) {
        self.layout = layout
        self.colors = colors
        self.fonts = fonts
    }

    // MARK: Public

    // MARK: Layout

    /// Sub-model containing layout properties.
    public struct Layout {
        // MARK: Lifecycle

        // MARK: Initializers

        /// Initializes sub-model with default values.
        public init() {}

        // MARK: Public

        // MARK: Properties

        /// Button height. Defaults to `40`.
        public var height: CGFloat = 40

        /// Button corner radius. Defaults to `20`.
        public var cornerRadius: CGFloat = 10
    }

    // MARK: Colors

    /// Sub-model containing color properties.
    public struct Colors {
        // MARK: Lifecycle

        // MARK: Initializers

        /// Initializes sub-model with content, text, and background colors.
        public init(content: StateOpacities, text: StateColors, background: StateColors) {
            self.content = content
            self.text = text
            self.background = background
        }

        // MARK: Public

        // MARK: State Colors

        /// Sub-model containing colors for component states.
        public typealias StateColors = StateColors_EPD

        // MARK: State Opacities

        /// Sub-model containing opacities for component states.
        public typealias StateOpacities = StateOpacities_P

        // MARK: Properties

        /// Conrent opacities.
        public var content: StateOpacities

        /// Text content colors.
        ///
        /// Only applicable when using init with title.
        public var text: StateColors

        /// Background colors.
        public var background: StateColors
    }

    // MARK: Fonts

    /// Sub-model containing font properties.
    public struct Fonts {
        // MARK: Lifecycle

        // MARK: Initializers

        /// Initializes sub-model with default values.
        public init() {}

        // MARK: Public

        // MARK: Properties

        /// Title font. Defaults to system font of size `16` with `semibold` weight.
        public var title: Font = primaryButtonReference.fonts.title
    }

    // MARK: Properties

    /// Reference to `VPrimaryButtonModel`.
    public static let primaryButtonReference: VPrimaryButtonModel = .init()

    /// Sub-model containing layout properties.
    public var layout: Layout

    /// Sub-model containing color properties.
    public var colors: Colors

    /// Sub-model containing font properties.
    public var fonts: Fonts

    // MARK: Fileprivate

    // MARK: Sub-Models

    fileprivate var primaryButtonSubModel: VPrimaryButtonModel {
        var model: VPrimaryButtonModel = .init()

        model.layout.height = layout.height
        model.layout.cornerRadius = layout.cornerRadius

        model.colors.content = .init(
            pressedOpacity: colors.content.pressedOpacity,
            disabledOpacity: VDialogButtonModelCustom.primaryButtonReference.colors.content
                .disabledOpacity
        )

        model.colors.textContent = .init(
            enabled: colors.text.enabled,
            pressed: colors.text.pressed,
            loading: VDialogButtonModelCustom.primaryButtonReference.colors.textContent.loading,
            disabled: colors.text.disabled
        )

        model.colors.background = .init(
            enabled: colors.background.enabled,
            pressed: colors.background.pressed,
            loading: VDialogButtonModelCustom.primaryButtonReference.colors.background.loading,
            disabled: colors.background.disabled
        )

        model.fonts.title = fonts.title

        return model
    }
}
