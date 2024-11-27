//
//  VLazyScrollViewVertical.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 12/24/20.
//

import SwiftUI

// MARK: - VLazyScrollViewVertical

struct VLazyScrollViewVertical<Content>: View where Content: View {
    // MARK: Lifecycle

    // MARK: Initializers

    init(
        model: VLazyScrollViewModelVertical,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.model = model
        self.content = content
    }

    // MARK: Internal

    // MARK: Body

    var body: some View {
        if #available(iOS 16.0, *) {
            ScrollView(.vertical, showsIndicators: model.misc.showIndicator, content: {
                LazyVStack(
                    alignment: model.layout.alignment,
                    spacing: model.layout.rowSpacing,
                    content: {
                        content()
                    }
                )
            }).scrollContentBackground(.hidden)
        } else {
            ScrollView(.vertical, showsIndicators: model.misc.showIndicator, content: {
                LazyVStack(
                    alignment: model.layout.alignment,
                    spacing: model.layout.rowSpacing,
                    content: {
                        content()
                    }
                )
            })
        }
    }

    // MARK: Private

    // MARK: Properties

    private let model: VLazyScrollViewModelVertical
    private let content: () -> Content
}

// MARK: - VLazyScrollViewVertical_Previews

struct VLazyScrollViewVertical_Previews: PreviewProvider {
    static var previews: some View {
        VLazyScrollViewVertical(model: .init(), content: {
            ForEach(1..<100, content: { num in
                Text(String(num))
            })
        })
    }
}
