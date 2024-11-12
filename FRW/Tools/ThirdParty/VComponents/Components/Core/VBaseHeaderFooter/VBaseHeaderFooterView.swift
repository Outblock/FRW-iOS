//
//  VBaseHeaderFooterView.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/25/21.
//

import SwiftUI

// MARK: - VBaseHeaderFooter

/// Core component that is used throughout the library.
///
/// Usage example:
///
///     var body: some View {
///         VBaseHeaderFooter(
///             frameType: .fixed
///             font: .body,
///             color: ColorBook.primary,
///             title: "Lorem ipsum dolor sit amet"
///         )
///     }
///
public struct VBaseHeaderFooter: View {
    // MARK: Lifecycle

    // MARK: Initializers

    /// Initializes component with frame type, font, color, and title.
    public init(
        frameType: VBaseHeaderFooterFrameType,
        font: Font,
        color: Color,
        title: String
    ) {
        self.frameType = frameType
        self.font = font
        self.color = color
        self.title = title
    }

    // MARK: Public

    // MARK: Body

    @ViewBuilder
    public var body: some View {
        switch frameType {
        case .fixed: contentView
        case let .flexible(alignment): contentView.frame(
                maxWidth: .infinity,
                alignment: alignment.asAlignment
            )
        }
    }

    // MARK: Private

    // MARK: Proeprties

    private let frameType: VBaseHeaderFooterFrameType
    private let textType: VTextType = .oneLine
    private let font: Font
    private let color: Color
    private let title: String

    private var contentView: some View {
        VText(
            type: textType,
            font: font,
            color: color,
            title: title
        )
    }
}

// MARK: - VBaseHeaderFooter_Previews

struct VBaseHeaderFooter_Previews: PreviewProvider {
    static var previews: some View {
        VSectionList_Previews.previews
    }
}
