//
//  OffsetScrollViewWithAppBar.swift
//  Flow Wallet
//
//  Created by cat on 2022/6/17.
//

import SwiftUI

// MARK: - OffsetScrollViewWithAppBar

struct OffsetScrollViewWithAppBar<Content: View, Nav: View>: View {
    // MARK: Lifecycle

    init(
        title: String = "",
        loadMoreEnabled: Bool = false,
        loadMoreCallback: (() -> Void)? = nil,
        isNoData: Bool = false,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder appBar: @escaping () -> Nav
    ) {
        self.content = content()
        self.navBar = appBar()
        self.title = title
        self.loadMoreCallback = loadMoreCallback
        self.isNoData = isNoData
        self.loadMoreEnabled = loadMoreEnabled
    }

    // MARK: Internal

    var title: String

    let content: Content
    let navBar: Nav

    /// Note: it will call multiple times, so you need guard it yourself.
    let loadMoreCallback: (() -> Void)?
    let isNoData: Bool
    let loadMoreEnabled: Bool

    var body: some View {
        OffsetScrollView(
            offset: $offset,
            loadMoreEnabled: loadMoreEnabled,
            loadMoreCallback: loadMoreCallback,
            isNoData: isNoData
        ) {
            content
        }
        .onChange(of: offset, perform: { value in
            if value < 0 {
                opacity = min(1, abs(value / 44.0))
            } else {
                opacity = 0
            }
        })
        .overlay(
            ZStack {
                Color.clear
                    .background(.ultraThinMaterial)
                    .opacity(opacity)
                navBar
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                if !title.isEmpty {
                    Text(title)
                        .font(.title2)
                        .foregroundColor(.LL.Neutrals.text)
                        .opacity(opacity)
                        .frame(maxWidth: screenWidth - 120)
                }
            }
            .frame(height: 44)
            .frame(maxHeight: .infinity, alignment: .top)
        )
    }

    // MARK: Private

    @State
    private var offset: CGFloat = 0
    @State
    private var opacity: CGFloat = 0
}

// MARK: - OffsetScrollWithAppBar_Previews

struct OffsetScrollWithAppBar_Previews: PreviewProvider {
    static var previews: some View {
        OffsetScrollViewWithAppBar {} appBar: {}
    }
}
