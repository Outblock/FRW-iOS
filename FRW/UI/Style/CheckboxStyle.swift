//
//  CheckboxStyle.swift
//  Flow Wallet
//
//  Created by Hao Fu on 6/1/22.
//

import Foundation
import SwiftUI

class CheckBoxStyle {
    static let primary: VCheckBoxModel = {
        var model = VCheckBoxModel()
        model.layout.dimension = 20
        model.layout.cornerRadius = 6
        model.layout.contentMarginLeading = 15
        model.colors.fill = .init(off: .clear,
                                  on: Color.LL.orange,
                                  indeterminate: Color.LL.orange,
                                  pressedOff: Color.LL.orange.opacity(0.5),
                                  pressedOn: Color.LL.orange.opacity(0.5),
                                  pressedIndeterminate: Color.LL.orange,
                                  disabled: .gray)

        model.colors.icon = .init(off: .clear,
                                  on: Color.LL.background,
                                  indeterminate: Color.LL.background,
                                  pressedOff: Color.LL.background.opacity(0.5),
                                  pressedOn: Color.LL.background.opacity(0.5),
                                  pressedIndeterminate: Color.LL.background,
                                  disabled: Color.LL.background)
        return model
    }()

    static let secondary: VCheckBoxModel = {
        var model = VCheckBoxModel()
        model.layout.dimension = 20
        model.layout.cornerRadius = 6
        model.fonts.title = .footnote
        model.layout.contentMarginLeading = 5
        model.colors.fill = .init(off: .clear,
                                  on: Color.LL.orange,
                                  indeterminate: Color.LL.orange,
                                  pressedOff: Color.LL.orange.opacity(0.5),
                                  pressedOn: Color.LL.orange.opacity(0.5),
                                  pressedIndeterminate: Color.LL.orange,
                                  disabled: .gray)

        model.colors.icon = .init(off: .clear,
                                  on: Color.LL.background,
                                  indeterminate: Color.LL.background,
                                  pressedOff: Color.LL.background.opacity(0.5),
                                  pressedOn: Color.LL.background.opacity(0.5),
                                  pressedIndeterminate: Color.LL.background,
                                  disabled: Color.LL.background)
        return model
    }()
}
