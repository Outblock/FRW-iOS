//
//  VPrimaryButtonModel.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 12/24/20.
//

import SwiftUI

// MARK: - V Primary Button Model

/// Model that describes UI.
public struct VPrimaryButtonModel {
    // MARK: Lifecycle

    /// Initializes model with default values.
    public init() {}

    // MARK: Public

    // MARK: Layout

    /// Sub-model containing layout properties.
    public struct Layout {
        // MARK: Lifecycle

        // MARK: Initializers

        /// Initializes sub-model with default values.
        public init() {}

        // MARK: Public

        // MARK: Content Margin

        /// Sub-model containing `horizontal` and `vertical` margins.
        public typealias ContentMargin = LayoutGroup_HV

        // MARK: Properties

        /// Button height. Defaults to `56`.
        public var height: CGFloat = 56

        /// Button corner radius. Defaults to `20`.
        public var cornerRadius: CGFloat = 20

        /// Button border width. Defaults to `0`.
        public var borderWidth: CGFloat = 0

        /// Content margin. Defaults to `15` horizontally and `3` vertically.
        public var contentMargin: ContentMargin = .init(
            horizontal: 15,
            vertical: 3
        )

        /// Spacing between content and spinner. Defaults to `20`.
        ///
        /// Only visible when state is set to `loading`.
        public var loaderSpacing: CGFloat = 20

        // MARK: Internal

        let loaderWidth: CGFloat = 10

        var hasBorder: Bool { borderWidth > 0 }
    }

    // MARK: Colors

    /// Sub-model containing color properties.
    public struct Colors {
        // MARK: Lifecycle

        // MARK: Initializers

        /// Initializes sub-model with default values.
        public init() {}

        // MARK: Public

        // MARK: State Colors

        /// Sub-model containing colors for component states.
        public typealias StateColors = StateColors_EPLD

        // MARK: State Opacities

        /// Sub-model containing opacities for component states.
        public typealias StateOpacities = StateOpacities_PD

        // MARK: Properties

        /// Content opacities.
        public var content: StateOpacities = .init(
            pressedOpacity: 0.5,
            disabledOpacity: 0.5
        )

        /// Text content colors.
        ///
        /// Only applicable when using init with title.
        public var textContent: StateColors = .init(
            enabled: ColorBook.primaryInverted,
            pressed: ColorBook.primaryInverted,
            loading: ColorBook.primaryInverted,
            disabled: ColorBook.primaryInverted
        )

        /// Background colors.
        public var background: StateColors = .init(
            enabled: .init(componentAsset: "PrimaryButton.Background.enabled"),
            pressed: .init(componentAsset: "PrimaryButton.Background.pressed"),
            loading: .init(componentAsset: "PrimaryButton.Background.disabled"),
            disabled: .init(componentAsset: "PrimaryButton.Background.disabled")
        )

        /// Border colors.
        public var border: StateColors = .init(
            enabled: .clear,
            pressed: .clear,
            loading: .clear,
            disabled: .clear
        )

        /// Loader colors.
        public var loader: Color = ColorBook.primaryInverted
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
        ///
        /// Only applicable when using init with title.
        public var title: Font = .system(size: 16, weight: .semibold)
    }

    // MARK: Properties

    /// Sub-model containing layout properties.
    public var layout: Layout = .init()

    /// Sub-model containing color properties.
    public var colors: Colors = .init()

    /// Sub-model containing font properties.
    public var fonts: Fonts = .init()

    // MARK: Internal

    // MARK: Sub-Models

    var spinnerSubModel: VSpinnerModelContinous {
        var model: VSpinnerModelContinous = .init()
        model.colors.spinner = colors.loader
        return model
    }
}
