//
//  VBaseListModel.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/10/21.
//

import SwiftUI

// MARK: - V Base List Model

/// Model that describes UI.
public struct VBaseListModel {
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

        // MARK: Horizontal Margins

        /// Sub-model containing `leading` and `trailing` margins.
        public typealias HorizontalMargins = LayoutGroup_LT

        // MARK: Properties

        /// Trailing margin. Defaults to `0`.
        ///
        /// Purpose of this property is to create a spacing between rows and scrolling indicator.
        public var marginTrailing: CGFloat = 0

        /// Spacing between rows. Defaults to `18`.
        public var rowSpacing: CGFloat = 18

        /// Row divider height. Defaults to `1`.
        public var dividerHeight: CGFloat = 1

        /// Divider margins. Defaults to `0` leading and `0` trailing.
        public var dividerMargins: HorizontalMargins = .init(
            leading: 0,
            trailing: 0
        )

        // MARK: Internal

        var dividerMarginVertical: CGFloat { rowSpacing / 2 }

        var hasDivider: Bool { dividerHeight > 0 }
    }

    // MARK: Colors

    /// Sub-model containing color properties.
    public struct Colors {
        // MARK: Lifecycle

        // MARK: Initializers

        /// Initializes sub-model with default values.
        public init() {}

        // MARK: Public

        // MARK: Properties

        /// Divider color.
        public var divider: Color = .init(componentAsset: "BaseList.Divider")
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

    /// Sub-model containing color properties.
    public var colors: Colors = .init()

    /// Sub-model containing misc properties.
    public var misc: Misc = .init()

    // MARK: Internal

    // MARK: Sub-Models

    var lazyScrollViewSubModel: VLazyScrollViewModelVertical {
        var model: VLazyScrollViewModelVertical = .init()
        model.misc.showIndicator = misc.showIndicator
        return model
    }
}
