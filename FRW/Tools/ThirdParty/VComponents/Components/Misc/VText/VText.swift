//
//  VText.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/7/21.
//

import SwiftUI

// MARK: - VText

/// Core component that is used throughout the library as text.
///
/// Usage example:
///
///     var body: some View {
///         VText(
///             type: .oneLine
///             font: .body,
///             color: ColorBook.primary,
///             title: "Lorem ipsum dolor sit amet"
///         )
///     }
///
public struct VText: View {
    // MARK: Lifecycle

    // MARK: Initializers

    /// Initializes component with type, font, color, and title.
    public init(
        type textType: VTextType,
        font: Font,
        color: Color,
        title: String
    ) {
        self.textType = textType
        self.font = font
        self.color = color
        self.title = title
    }

    // MARK: Public

    // MARK: Body

    @ViewBuilder
    public var body: some View {
        switch textType {
        case .oneLine:
            Text(title)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundColor(color)
                .font(font)
                .minimumScaleFactor(0.5)

        case let .multiLine(limit, alignment):
            Text(title)
                .lineLimit(limit)
                .multilineTextAlignment(alignment)
                .truncationMode(.tail)
                .foregroundColor(color)
                .font(font)
                .minimumScaleFactor(0.5)
        }
    }

    // MARK: Private

    // MARK: Properties

    private let textType: VTextType
    private let font: Font
    private let color: Color
    private let title: String
}

// MARK: - VText_Previews

struct VText_Previews: PreviewProvider {
    static var previews: some View {
        VText(
            type: .oneLine,
            font: .body,
            color: ColorBook.primary,
            title: "Lorem ipsum dolor sit amet"
        )
    }
}
