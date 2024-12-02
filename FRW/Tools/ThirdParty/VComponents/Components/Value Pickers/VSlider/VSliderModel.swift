//
//  VSliderModel.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 12/21/20.
//

import SwiftUI

// MARK: - V Slider Model

/// Model that describes UI.
public struct VSliderModel {
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

        // MARK: Properties

        /// Slider height. Defaults to `10`.
        public var height: CGFloat = 10

        /// Slider corner radius. Defaults to `5`.
        public var cornerRadius: CGFloat = 5

        /// Thumb dimension. Defaults to `20`.
        public var thumbDimension: CGFloat = 20

        /// Thumb corner radius. Defaults to `10`.
        public var thumbCornerRadius: CGFloat = 10

        /// Thumb border widths. Defaults to `0`.
        public var thumbBorderWidth: CGFloat = 0

        /// Thumb shadow radius. Defaults to `2`.
        public var thumbShadowRadius: CGFloat = 2

        // MARK: Internal

        var hasThumb: Bool { thumbDimension > 0 }
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
        public typealias StateColors = StateColors_ED

        // MARK: Properties

        /// Slider track colors.
        public var track: StateColors = .init(
            enabled: VSliderModel.toggleReference.colors.fill.off,
            disabled: VSliderModel.toggleReference.colors.fill.disabled
        )

        /// Slider progress colors.
        public var progress: StateColors = .init(
            enabled: VSliderModel.toggleReference.colors.fill.on,
            disabled: VSliderModel.primaryButtonReference.colors.background.disabled
        )

        /// Thumb colors.
        public var thumb: StateColors = .init(
            enabled: VSliderModel.toggleReference.colors.thumb.on,
            disabled: VSliderModel.toggleReference.colors.thumb.on
        )

        /// Thumb border colors.
        public var thumbBorder: StateColors = .init(
            enabled: .init(componentAsset: "Slider.Thumb.Border.enabled"),
            disabled: .init(componentAsset: "Slider.Thumb.Border.disabled")
        )

        /// Thumb shadow colors.
        public var thumbShadow: StateColors = .init(
            enabled: .init(componentAsset: "Slider.Thumb.Shadow.enabled"),
            disabled: .init(componentAsset: "Slider.Thumb.Shadow.disabled")
        )
    }

    // MARK: Animations

    /// Sub-model containing animation properties.
    public struct Animations {
        // MARK: Lifecycle

        // MARK: Initializers

        /// Initializes sub-model with default values.
        public init() {}

        // MARK: Public

        // MARK: Properties

        /// Progress animation. Defaults to `nil`.
        public var progress: Animation?
    }

    // MARK: Properties

    /// Reference to `VPrimaryButtonModel`.
    public static let primaryButtonReference: VPrimaryButtonModel = .init()

    /// Reference to `VToggleModel`.
    public static let toggleReference: VToggleModel = .init()

    /// Sub-model containing layout properties.
    public var layout: Layout = .init()

    /// Sub-model containing color properties.
    public var colors: Colors = .init()

    /// Sub-model containing animation properties.
    public var animations: Animations = .init()
}
