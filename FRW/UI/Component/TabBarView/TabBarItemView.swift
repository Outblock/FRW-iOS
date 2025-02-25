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
    
    ///So that we update our color when appearance changes.
    @ObservedObject
    private var style = ThemeManager.shared

    var body: some View {
        Button(action: {
            withAnimation(.spring()) { selected = pageModel.tag }
            action()
        }, label: {
            VStack(spacing: 2) {
                icon
                title
            }
            .padding(.top, 8)
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contextMenu {
            if let m = pageModel.contextMenu {
                m()
            }
        }
        .tint(tint)
    }
    
    @ViewBuilder
    private var icon: some View {
        Image(pageModel.iconName + (selected == pageModel.tag ? "-selected" : "") )
            .aspectRatio(contentMode: .fit)
            .frame(width: 28, height: 28)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private var title: some View {
        Text(pageModel.title)
            .font(.inter(size: 12, weight: .semibold))
    }
    
    @ViewBuilder
    private var tint: Color {
        selected == pageModel.tag ? Color.Theme.Accent.green : Color.TabIcon.unselectedTint
    }
}

#Preview {
    let wallet = TabBarPageModel<AppTabType>(
        tag: WalletHomeView.tabTag(),
        iconName: WalletHomeView.iconName(),
        title: WalletHomeView.title()
    ) {
        AnyView(WalletHomeView())
    }
    TabBarItemView(pageModel: wallet, selected: .constant(.wallet), action: { })
}
