//
//  TabBarItemView.swift
//  Test
//
//  Created by cat on 2022/5/25.
//

import SwiftUI

// MARK: - TabBarItemView

struct TabBarItemView<T: Hashable>: View {
    var pageModel: TabBarPageModel<T>
    @Binding
    var selected: T
    var action: () -> Void

    @ViewBuilder
    var icon: some View {
        Image(pageModel.iconName + (selected == pageModel.tag ? "-selected" : "") )
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .tint(selected == pageModel.tag ? Color.Theme.Accent.green : Color.TabIcon.unselectedTint)
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring()) { selected = pageModel.tag }
            action()
        }, label: {
            icon
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contextMenu {
            if let m = pageModel.contextMenu {
                m()
            }
        }
    }
}
