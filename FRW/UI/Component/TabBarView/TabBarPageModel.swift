//
//  TabBarPageModel.swift
//  Test
//
//  Created by Selina on 26/5/2022.
//

import Lottie
import SwiftUI

struct TabBarPageModel<T: Hashable> {
    // MARK: Lifecycle

    init(
        tag: T,
        iconName: String,
        view: @escaping () -> AnyView,
        contextMenu: (() -> AnyView)? = nil
    ) {
        self.tag = tag
        self.iconName = iconName
        self.view = view
        self.contextMenu = contextMenu
    }

    // MARK: Internal

    let tag: T
    let iconName: String
    let view: () -> AnyView
    let contextMenu: (() -> AnyView)?
}
