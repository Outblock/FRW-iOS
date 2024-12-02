//
//  VBaseButtonViewRepresentable.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/19/21.
//

import SwiftUI

// MARK: - V Base Button View Representable

struct VBaseButtonViewRepresentable: UIViewRepresentable {
    // MARK: Lifecycle

    // MARK: Initializers

    init(
        isEnabled: Bool,
        gesture gestureHandler: @escaping (VBaseButtonGestureState) -> Void
    ) {
        self.isEnabled = isEnabled
        self.gestureHandler = gestureHandler
    }

    // MARK: Internal

    // MARK: Representable

    func makeUIView(context _: Context) -> UIView {
        let view: UIView = .init(frame: .zero)

        DispatchQueue.main.async {
            let gestureRecognizer: VBaseButtonTapGestureRecognizer = .init(gesture: gestureHandler)

            self.gestureRecognizer = gestureRecognizer
            view.addGestureRecognizer(gestureRecognizer)
        }

        // setBindedValues(view, context: context)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        setBindedValues(uiView, context: context)
    }

    // MARK: Private

    // MARK: Properties

    private let isEnabled: Bool
    private let gestureHandler: (VBaseButtonGestureState) -> Void

    @State
    private var gestureRecognizer: VBaseButtonTapGestureRecognizer?

    private func setBindedValues(_ view: UIView, context _: Context) {
        view.isUserInteractionEnabled = isEnabled

        gestureRecognizer?.update(gesture: gestureHandler)
    }
}
