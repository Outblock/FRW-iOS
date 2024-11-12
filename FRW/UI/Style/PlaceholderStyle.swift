//
//  PlaceholderStyle.swift
//  Flow Wallet
//
//  Created by Selina on 12/7/2022.
//

import SwiftUI

public struct PlaceholderStyle: ViewModifier {
    // MARK: Public

    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                    .lineLimit(1)
                    .padding(.horizontal, 0)
                    .foregroundColor(color)
                    .font(font)
            }
            content
        }
    }

    // MARK: Internal

    var showPlaceHolder: Bool
    var placeholder: String
    var font: Font
    var color: Color
}
