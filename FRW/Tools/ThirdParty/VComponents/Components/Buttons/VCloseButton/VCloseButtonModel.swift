//
//  VCloseButtonModel.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/13/21.
//

import SwiftUI

// MARK: - V Close Button Model

/// Model that describes UI.
public struct VCloseButtonModel {
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

        /// Initializes sub-model with default values
        public init() {}

        // MARK: Public

        // MARK: Hit Box

        /// Sub-model containing `horizontal` and `vertical` hit boxes
        public typealias HitBox = LayoutGroup_HV

        // MARK: Properties

        /// Button dimension. Default to `32`.
        public var dimension: CGFloat = chevronButtonReference.layout.dimension

        /// Icon dimension. Default to `11`.
        public var iconDimension: CGFloat = 11

        /// Hit box. Defaults to `0` horizontally and `0` vertically.
        public var hitBox: HitBox = chevronButtonReference.layout.hitBox
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

        /// Content colors.
        public var content: StateColorsAndOpacities = chevronButtonReference.colors.content

        /// Background colors.
        public var background: StateColors = chevronButtonReference.colors.background
    }

    // MARK: Properties

    /// Reference to `VChevronButtonModel`.
    public static let chevronButtonReference: VChevronButtonModel = .init()

    /// Sub-model containing layout properties.
    public var layout: Layout = .init()

    /// Sub-model containing color properties.
    public var colors: Colors = .init()
}
