//
//  DragGestureViewModifier.swift
//  Flow Wallet
//
//  Created by Hao Fu on 5/9/2022.
//

import Foundation
import SwiftUI

typealias Callback = () -> Void

struct DragGestureViewModifier: ViewModifier {
    @GestureState private var isDragging: Bool = false
    @State var gestureState: GestureStatus = .idle

    var onStart: Callback?
    var onUpdate: ((DragGesture.Value) -> Void)?
    var onEnd: Callback?
    var onCancel: Callback?

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .updating($isDragging) { _, isDragging, _ in
                        isDragging = true
                    }
                    .onChanged(onDragChange(_:))
                    .onEnded(onDragEnded(_:))
            )
            .onChange(of: gestureState) { state in
                guard state == .started else { return }
                gestureState = .active
            }
            .onChange(of: isDragging) { value in
                if value, gestureState != .started {
                    gestureState = .started
                    onStart?()
                } else if !value, gestureState != .ended {
                    gestureState = .cancelled
                    onCancel?()
                }
            }
    }

    func onDragChange(_ value: DragGesture.Value) {
        guard gestureState == .started || gestureState == .active else { return }
        onUpdate?(value)
    }

    func onDragEnded(_: DragGesture.Value) {
        gestureState = .ended
        onEnd?()
    }

    enum GestureStatus: Equatable {
        case idle
        case started
        case active
        case ended
        case cancelled
    }
}
