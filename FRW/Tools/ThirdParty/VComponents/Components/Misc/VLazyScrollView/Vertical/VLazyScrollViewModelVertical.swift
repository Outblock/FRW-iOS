//
//  VLazyScrollViewModelVertical.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 19.12.20.
//

import SwiftUI

// MARK: - V Lazy Scroll View Model Vertical

/// Model that describes UI.
public struct VLazyScrollViewModelVertical {
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

        /// Row spacing. Defaults to `0`.
        public var rowSpacing: CGFloat = 0

        /// Row alignment. Defaults to .`center`.
        public var alignment: HorizontalAlignment = .center
    }

    // MARK: Misc

    /// Sub-model containing misc properties.
    public struct Misc {
        // MARK: Lifecycle

        // MARK: Initializers

        /// Initializes sub-model with default values.
        public init() {}

        // MARK: Public

        // MARK: Properties

        /// Indicates if scrolling indicator is shown. Defaults to `true`.
        public var showIndicator: Bool = true
    }

    // MARK: Properties

    /// Sub-model containing layout properties.
    public var layout: Layout = .init()

    /// Sub-model containing misc properties.
    public var misc: Misc = .init()
}
