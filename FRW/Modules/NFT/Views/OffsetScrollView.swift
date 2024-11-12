//
//  OffsetScrollView.swift
//  Sky
//
//  Created by cat on 2022/6/1.
//

import SwiftUI

// MARK: - PaginatedScrollViewKey

private enum PaginatedScrollViewKey {
    enum Direction {
        case top, bottom
    }

    struct PreData: Equatable {
        // MARK: Internal

        static var fraction = CGFloat(0.001)

        let top: CGFloat
        let bottom: CGFloat

        var position: Direction {
            abTop > abBottom ? .bottom : .top
        }

        var isAtTop: Bool {
            top > PreData.fraction
        }

        var isAtBottom: Bool {
            let percentage = (bottom / contentHeight)
            return percentage < PreData.fraction
        }

        // MARK: Private

        private var abTop: CGFloat { abs(min(0, top)) }
        private var abBottom: CGFloat { abs(max(0, bottom)) }

        private var contentHeight: CGFloat {
            abs(top - bottom)
        }
    }

    struct PreKey: PreferenceKey {
        static var defaultValue: PreData? = nil

        static func reduce(value _: inout PreData?, nextValue _: () -> PreData?) {}
    }
}

private let RefreshOffset: CGFloat = 70

// MARK: - OffsetScrollView

struct OffsetScrollView<Content: View>: View {
    // MARK: Lifecycle

    init(
        offset: Binding<CGFloat>,
        refreshEnabled: Bool = false,
        loadMoreEnabled: Bool = false,
        refreshCallback: (() -> Void)? = nil,
        loadMoreCallback: (() -> Void)? = nil,
        isNoData: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.refreshEnabled = refreshEnabled
        self.refreshCallback = refreshCallback
        self.loadMoreEnabled = loadMoreEnabled
        self.loadMoreCallback = loadMoreCallback
        self.isNoData = isNoData
        _offset = offset
    }

    // MARK: Internal

    @Binding
    var offset: CGFloat

    let refreshEnabled: Bool
    let loadMoreEnabled: Bool

    /// Note: it will call multiple times, so you need guard it yourself.
    let refreshCallback: (() -> Void)?

    /// Note: it will call multiple times, so you need guard it yourself.
    let loadMoreCallback: (() -> Void)?
    let isNoData: Bool

    let content: Content

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    GeometryReader { geo in
                        Color.clear
                            .preference(
                                key: NavigationScrollPreferenKey.self,
                                value: geo.frame(in: .named("ScrollView")).minY
                            )
                    }
                    .frame(width: 0, height: 0)

                    VStack(spacing: 0) {
                        content
                        if loadMoreEnabled {
                            loadMoreView
                        }
                    }
                    .anchorPreference(key: PaginatedScrollViewKey.PreKey.self, value: .bounds) {
                        let frame = geometry[$0]
                        let top = frame.minY
                        let bottom = frame.maxY - geometry.size.height
                        return PaginatedScrollViewKey.PreData(top: top, bottom: bottom)
                    }
                }
                .frame(alignment: .top)
                .coordinateSpace(name: "ScrollView")
                .onPreferenceChange(NavigationScrollPreferenKey.self) { value in
                    self.offset = value
                }
                .onPreferenceChange(PaginatedScrollViewKey.PreKey.self) { data in
                    guard let data = data else { return }
                    if data.bottom == 0, loadMoreEnabled, !isNoData {
                        loadMoreCallback?()
                    }
                }

//                if refreshEnabled {
//                    refreshView
//                        .opacity(refreshOpacity)
//                }
            }
        }
    }

    var refreshOpacity: CGFloat {
        if offset < 0 {
            return 0
        }

        let percent = abs(offset / RefreshOffset)
        return max(0, min(1, percent))
    }

    var refreshView: some View {
        VStack {
            ProgressView()
                .progressViewStyle(.circular)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, UIView.topSafeAreaHeight + 44)
    }

    var loadMoreView: some View {
        VStack {
            Text(isNoData ? "no_more_data".localized : "loading_more".localized)
                .font(.inter(size: 14))
                .foregroundColor(Color.LL.Neutrals.note)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
    }
}

// MARK: - NavigationScrollPreferenKey

private class NavigationScrollPreferenKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value _: inout CGFloat, nextValue _: () -> CGFloat) {}
}

// MARK: - NavigationScrollView_Previews

struct NavigationScrollView_Previews: PreviewProvider {
    static var previews: some View {
        OffsetScrollView(offset: .constant(1)) {
            LazyVStack {
                ForEach(0 ..< 200) { index in
                    Text("Row number \(index)")
                        .padding()
                }
            }
        }
        .preferredColorScheme(.light)
    }
}
