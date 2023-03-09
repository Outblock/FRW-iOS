//
//  TabBarPageModel.swift
//  Test
//
//  Created by Selina on 26/5/2022.
//

import SwiftUI
import Lottie

struct TabBarPageModel<T: Hashable> {
    let tag: T
    let iconName: String
    let color: SwiftUI.Color
    let view: () -> AnyView
    let contextMenu: (() -> AnyView)?
    let lottieView: AnimationView

    init(tag: T, iconName: String, color: SwiftUI.Color, view: @escaping () -> AnyView, contextMenu: (() -> AnyView)? = nil) {
        self.tag = tag
        self.iconName = iconName
        self.color = color
        self.view = view
        self.contextMenu = contextMenu
        self.lottieView = AnimationView(name: iconName, bundle: .main)
    }
}
