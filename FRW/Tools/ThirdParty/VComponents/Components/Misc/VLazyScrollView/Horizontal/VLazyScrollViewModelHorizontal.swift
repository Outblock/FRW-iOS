//
//  VLazyScrollViewModelHorizontal.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 12/24/20.
//

import SwiftUI

// MARK: - V Lazy Scroll View Model Horizontal

/// Model that describes UI.
public struct VLazyScrollViewModelHorizontal {
    // MARK: Properties

    /// Sub-model containing layout properties.
    public var layout: Layout = .init()

    /// Sub-model containing misc properties.
    public var misc: Misc = .init()

    // MARK: Initializers

    /// Initializes model with default values.
    public init() {}

    // MARK: Layout

    /// Sub-model containing layout properties.
    public struct Layout {
        // MARK: Properties

        /// Row spacing. Defaults to `0`.
        public var rowSpacing: CGFloat = 0

        /// Row alignment. Defaults to .`center`.
        public var alignment: VerticalAlignment = .center

        // MARK: Initializers

        /// Initializes sub-model with default values.
        public init() {}
    }

    // MARK: Misc

    /// Sub-model containing misc properties.
    public struct Misc {
        // MARK: Properties

        /// Indicates if scrolling indicator is shown. Defaults to `true`.
        public var showIndicator: Bool = true

        // MARK: Initializers

        /// Initializes sub-model with default values.
        public init() {}
    }
}
