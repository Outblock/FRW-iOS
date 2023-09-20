//
//  PlaceholderStyle.swift
//  Flow Reference Wallet
//
//  Created by Selina on 12/7/2022.
//

import SwiftUI

public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String
    var font: Font
    var color: Color

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
}
