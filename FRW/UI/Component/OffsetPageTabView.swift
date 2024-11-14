//
//  OffsetPageTabView.swift
//  Flow Wallet-lite
//
//  Created by Hao Fu on 27/11/21.
//

import SwiftUI

// Custom View that will return offset for Paging Control....
struct OffsetPageTabView<Content: View>: UIViewRepresentable {
    // MARK: Lifecycle

    init(
        offset: Binding<CGFloat>,
        scrollTo: Binding<CGFloat>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content()
        _offset = offset
        _scrollTo = scrollTo
    }

    // MARK: Internal

    // Pager Offset...
    class Coordinator: NSObject, UIScrollViewDelegate {
        // MARK: Lifecycle

        init(parent: OffsetPageTabView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: OffsetPageTabView

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offset = scrollView.contentOffset.x
            parent.offset = offset
            parent.scrollTo = -1
        }

        func scrollViewDidEndScrollingAnimation(_: UIScrollView) {
            parent.scrollTo = -1
        }
    }

    var content: Content

    @Binding
    var offset: CGFloat

    @Binding
    var scrollTo: CGFloat

    func makeCoordinator() -> Coordinator {
        OffsetPageTabView.Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollview = UIScrollView()

        // Extracting SwiftUI View and embedding into UIKit ScrollView...
        let hostview = UIHostingController(rootView: content)
        hostview.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            hostview.view.topAnchor.constraint(equalTo: scrollview.topAnchor),
            hostview.view.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor),
            hostview.view.trailingAnchor.constraint(equalTo: scrollview.trailingAnchor),
            hostview.view.bottomAnchor.constraint(equalTo: scrollview.bottomAnchor),

            // if you are using vertical Paging...
            // then dont declare height constraint...
            hostview.view.heightAnchor.constraint(equalTo: scrollview.heightAnchor),
        ]

        hostview.view.backgroundColor = nil

        scrollview.addSubview(hostview.view)
        scrollview.addConstraints(constraints)

        // ENabling Paging...
        scrollview.isPagingEnabled = true
        scrollview.showsVerticalScrollIndicator = false
        scrollview.showsHorizontalScrollIndicator = false

        scrollview.bounces = false
        scrollview.alwaysBounceHorizontal = false

        // setting Delegate...
        scrollview.delegate = context.coordinator

        scrollview.backgroundColor = nil

        return scrollview
    }

    func updateUIView(_ uiView: UIScrollView, context _: Context) {
        // need to update only when offset changed manually...
        // just check the current and scrollview offsets...
        let currentOffset = uiView.contentOffset.x

        if currentOffset != offset {
            uiView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        }

        if scrollTo != -1 {
            uiView.setContentOffset(CGPoint(x: scrollTo, y: 0), animated: false)
        }
    }
}
