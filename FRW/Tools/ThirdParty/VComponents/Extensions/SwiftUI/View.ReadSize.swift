//
//  View.ReadSize.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 10/28/21.
//

import SwiftUI

// MARK: - Read Size

public extension View {
    /// Reads `View` size and calls an on-change block.
    func readSize(
        onChange completion: @escaping (CGSize) -> Void
    ) -> some View {
        background(
            GeometryReader(content: { proxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: proxy.size)
            })
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: completion)
    }
}

// MARK: - SizePreferenceKey

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value _: inout CGSize, nextValue _: () -> CGSize) {}
}
