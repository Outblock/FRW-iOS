//
//  VChevronButtonModel.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 12/23/20.
//

import SwiftUI

// MARK: - V Chevron Button Model

/// Model that describes UI.
public struct VChevronButtonModel {
    // MARK: Lifecycle

    // MARK: Initializers

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

        // MARK: Hit Box

        /// Sub-model containing `horizontal` and `vertical` hit boxes.
        public typealias HitBox = LayoutGroup_HV

        // MARK: Properties

        /// Button dimension. Default to `32`.
        public var dimension: CGFloat = 32

        /// Icon dimension. Default to `12`.
        public var iconDimension: CGFloat = 12

        /// Hit box. Defaults to `0` horizontally and `0` vertically.
        public var hitBox: HitBox = .init(
            horizontal: 0,
            vertical: 0
        )

        // MARK: Internal

        var navigationBarBackButtonOffsetX: CGFloat?
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
        public typealias StateColors = StateColors_EPD

        // MARK: State Colors and Opacities

        /// Sub-model containing colors and opacities for component states.
        public typealias StateColorsAndOpacities = StateColorsAndOpacities_EPD_PD

        // MARK: Properties

        /// Content colors and opacities.
        public var content: StateColorsAndOpacities = .init(
            enabled: ColorBook.primary,
            pressed: ColorBook.primary,
            disabled: ColorBook.primary,
            pressedOpacity: 0.5,
            disabledOpacity: 0.5
        )

        /// Background colors.
        public var background: StateColors = .init(
            enabled: .init(componentAsset: "ChevronButton.Background.enabled"),
            pressed: .init(componentAsset: "ChevronButton.Background.pressed"),
            disabled: .init(componentAsset: "ChevronButton.Background.disabled")
        )
    }

    // MARK: Properties

    /// Sub-model containing layout properties.
    public var layout: Layout = .init()

    /// Sub-model containing color properties.
    public var colors: Colors = .init()
}
