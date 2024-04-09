//
//  TextFieldStyle.swift
//  Flow Wallet
//
//  Created by Hao Fu on 2/1/22.
//

import Foundation
import SwiftUI

class TextFieldStyle {
    static let primary: VTextFieldModel = {
        var model: VTextFieldModel = .init()

        model.misc.autoCorrect = .no
        model.misc.autoCapitalization = .none
        model.colors.background = .clear
        model.colors.border = .init(enabled: Color.LL.rebackground.opacity(0.2),
                                    focused: Color.LL.rebackground.opacity(0.6),
                                    success: Color.LL.rebackground.opacity(0.6),
                                    error: Color.LL.rebackground.opacity(0.6),
                                    disabled: .clear)

        model.colors.clearButtonBackground = .init(enabled: .separator,
                                                   focused: .separator,
                                                   success: .separator,
                                                   error: .separator,
                                                   pressedEnabled: .separator.opacity(0.5),
                                                   pressedFocused: .separator.opacity(0.5),
                                                   pressedSuccess: .separator.opacity(0.5),
                                                   pressedError: .separator.opacity(0.5),
                                                   disabled: .separator.opacity(0.5))

        model.colors.clearButtonIcon =
//            .clear
            .init(enabled: Color.LL.background,
                  focused: Color.LL.background,
                  success: Color.LL.background,
                  error: Color.LL.background,
                  pressedEnabled: Color.LL.background.opacity(0.5),
                  pressedFocused: Color.LL.background.opacity(0.5),
                  pressedSuccess: Color.LL.background.opacity(0.5),
                  pressedError: Color.LL.background.opacity(0.5),
                  disabled: Color.LL.background.opacity(0.5),
                  pressedOpacity: 0.5,
                  disabledOpacity: 0.1)

        model.colors.footer = .init(enabled: Color.LL.note,
                                    focused: Color.LL.note,
                                    success: Color.LL.success,
                                    error: Color.LL.error,
                                    disabled: Color.LL.note)

        model.layout.cornerRadius = 16
        model.layout.height = 60
        model.layout.headerFooterSpacing = 8
        return model
    }()
}
