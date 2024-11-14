//
//  VBaseViewSwipeGesture.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 12/22/20.
//

import SwiftUI

// MARK: - Modifier

extension View {
    func addNavigationBarSwipeGesture(completion: @escaping () -> Void) -> some View {
        modifier(VBaseViewSwipeGesture(completion: completion))
    }
}

// MARK: - VBaseViewSwipeGesture

struct VBaseViewSwipeGesture: ViewModifier {
    // MARK: Lifecycle

    // MARK: Initializers

    init(
        completion: @escaping () -> Void
    ) {
        self.completion = completion
    }

    // MARK: Internal

    // MARK: Body

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onEnded { value in
                        guard value.startLocation.x <= edgeOffset,
                              value.translation.width >= distanceToSwipe
                        else {
                            return
                        }

                        completion()
                    }
            )
    }

    // MARK: Private

    // MARK: Properties

    private let completion: () -> Void

    private let edgeOffset: CGFloat = 20
    private let distanceToSwipe: CGFloat = 100
}
