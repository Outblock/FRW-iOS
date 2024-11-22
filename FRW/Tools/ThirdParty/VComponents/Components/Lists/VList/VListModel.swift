//
//  VListModel.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/10/21.
//

import SwiftUI

// MARK: - V List Model

/// Model that describes UI.
public struct VListModel {
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
        public typealias HorizontalMargins = VBaseListModel.Layout.HorizontalMargins

        // MARK: Properties

        /// List corner radius. Defaults to `15`.
        public var cornerRadius: CGFloat = sheetReference.layout.cornerRadius

        /// Content margin. Defaults to `10`.
        public var contentMargin: CGFloat = sheetReference.layout.contentMargin

        /// Spacing between rows. Defaults to `18`.
        public var rowSpacing: CGFloat = baseListReference.layout.rowSpacing

        /// Row divider height. Defaults to `1`.
        public var dividerHeight: CGFloat = baseListReference.layout.dividerHeight

        /// Divider margins. Defaults to `0` leading and `0` trailing.
        public var dividerMargins: HorizontalMargins = baseListReference.layout.dividerMargins
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

        /// Row divider color.
        public var divider: Color = baseListReference.colors.divider

        /// Background color.
        public var background: Color = sheetReference.colors.background
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

    /// Reference to `VBaseListModel`.
    public static let baseListReference: VBaseListModel = .init()

    /// Reference to `VSheetModel`.
    public static let sheetReference: VSheetModel = .init()

    /// Sub-model containing layout properties.
    public var layout: Layout = .init()

    /// Sub-model containing color properties.
    public var colors: Colors = .init()

    /// Sub-model containing misc properties.
    public var misc: Misc = .init()

    // MARK: Internal

    // MARK: Sub-Models

    var baseListSubModel: VBaseListModel {
        var model: VBaseListModel = .init()

        model.misc.showIndicator = misc.showIndicator

        model.layout.marginTrailing = layout.contentMargin
        model.layout.rowSpacing = layout.rowSpacing
        model.layout.dividerHeight = layout.dividerHeight
        model.layout.dividerMargins = layout.dividerMargins

        model.colors.divider = colors.divider

        return model
    }

    var sheetSubModel: VSheetModel {
        var model: VSheetModel = .init()

        model.layout.cornerRadius = layout.cornerRadius
        model.layout.contentMargin = 0

        model.colors.background = colors.background

        return model
    }
}
