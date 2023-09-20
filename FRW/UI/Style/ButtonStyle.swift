//
//  ButtonStyle.swift
//  Flow Reference Wallet
//
//  Created by Hao Fu on 2/1/22.
//

import SwiftUI

class ButtonStyle {
    public static let stakePrimary: VPrimaryButtonModel = {
        var model: VPrimaryButtonModel = .init()

        model.fonts.title = Font.LL.body.bold()

        model.colors.textContent = .init(enabled: Color.white,
                                         pressed: Color.white.opacity(0.5),
                                         loading: Color.white,
                                         disabled: Color.white)

        model.colors.background = .init(enabled: Color.LL.stakeMain,
                                        pressed: Color.LL.stakeMain.opacity(0.5),
                                        loading: Color.LL.stakeMain,
                                        disabled: Color.LL.disable)

        model.layout.cornerRadius = 16
        return model
    }()
    
    public static let primary: VPrimaryButtonModel = {
        var model: VPrimaryButtonModel = .init()

        model.fonts.title = Font.LL.body.bold()

        model.colors.textContent = .init(enabled: Color.LL.frontColor,
                                         pressed: Color.LL.frontColor.opacity(0.5),
                                         loading: Color.LL.frontColor,
                                         disabled: Color.LL.frontColor)

        model.colors.background = .init(enabled: Color.LL.rebackground,
                                        pressed: Color.LL.rebackground.opacity(0.5),
                                        loading: Color.LL.rebackground,
                                        disabled: Color.LL.disable)

        model.layout.cornerRadius = 16
        return model
    }()

    public static let border: VPrimaryButtonModel = {
        var model: VPrimaryButtonModel = .init()

        model.fonts.title = Font.LL.body.bold()
        model.layout.borderWidth = 1
        model.colors.textContent = .init(enabled: Color.LL.rebackground,
                                         pressed: Color.LL.rebackground.opacity(0.5),
                                         loading: Color.LL.rebackground,
                                         disabled: Color.LL.rebackground)

        model.colors.background = .clear

        model.colors.border = .init(enabled: Color.LL.rebackground,
                                    pressed: Color.LL.rebackground.opacity(0.5),
                                    loading: Color.LL.rebackground,
                                    disabled: Color.LL.rebackground)

        model.layout.cornerRadius = 16
        return model
    }()

    public static let plain: VPrimaryButtonModel = {
        var model: VPrimaryButtonModel = .init()

        model.fonts.title = Font.LL.body.bold()
//        model.layout.borderWidth = 1
        model.colors.textContent = .init(enabled: Color.LL.rebackground,
                                         pressed: Color.LL.rebackground.opacity(0.5),
                                         loading: Color.LL.rebackground,
                                         disabled: Color.LL.rebackground)

        model.colors.background = .clear

        model.layout.cornerRadius = 16
        return model
    }()
}
