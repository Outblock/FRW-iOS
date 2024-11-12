//
//  PopupViewUtils.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 01.06.2022.
//  Copyright © 2022 Exyte. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - DispatchWorkHolder

final class DispatchWorkHolder {
    var work: DispatchWorkItem?
}

// MARK: - ClassReference

final class ClassReference<T> {
    // MARK: Lifecycle

    init(_ value: T) {
        self.value = value
    }

    // MARK: Internal

    var value: T
}

extension View {
    @ViewBuilder
    func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
        if #available(iOS 14.0, tvOS 14.0, macOS 11.0, watchOS 7.0, *) {
            self.onChange(of: value, perform: onChange)
        } else {
            onReceive(Just(value)) { value in
                onChange(value)
            }
        }
    }
}

extension View {
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func addTapIfNotTV(if condition: Bool, onTap: @escaping () -> Void) -> some View {
        #if os(tvOS)
        self
        #else
        if condition {
            gesture(
                TapGesture().onEnded {
                    onTap()
                }
            )
        } else {
            self
        }
        #endif
    }
}

// MARK: - FrameGetter

struct FrameGetter: ViewModifier {
    @Binding
    var frame: CGRect

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> AnyView in
                    DispatchQueue.main.async {
                        let rect = proxy.frame(in: .global)
                        // This avoids an infinite layout loop
                        if rect.integral != self.frame.integral {
                            self.frame = rect
                        }
                    }
                    return AnyView(EmptyView())
                }
            )
    }
}

extension View {
    func frameGetter(_ frame: Binding<CGRect>) -> some View {
        modifier(FrameGetter(frame: frame))
    }
}

// MARK: - SafeAreaGetter

struct SafeAreaGetter: ViewModifier {
    @Binding
    var safeArea: EdgeInsets

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> AnyView in
                    DispatchQueue.main.async {
                        let area = proxy.safeAreaInsets
                        // This avoids an infinite layout loop
                        if area != self.safeArea {
                            self.safeArea = area
                        }
                    }
                    return AnyView(EmptyView())
                }
            )
    }
}

extension View {
    public func safeAreaGetter(_ safeArea: Binding<EdgeInsets>) -> some View {
        modifier(SafeAreaGetter(safeArea: safeArea))
    }
}

// MARK: - AnimationCompletionObserverModifier

struct AnimationCompletionObserverModifier<Value>: AnimatableModifier where Value: VectorArithmetic,
    Value: Comparable {
    // MARK: Lifecycle

    init(observedValue: Value, completion: @escaping () -> Void) {
        self.completion = completion
        self.animatableData = observedValue
        self.targetValue = observedValue
    }

    // MARK: Internal

    /// While animating, SwiftUI changes the old input value to the new target value using this property. This value is set to the old value until the animation completes.
    var animatableData: Value {
        didSet {
            notifyCompletionIfFinished()
        }
    }

    func body(content: Content) -> some View {
        /// We're not really modifying the view so we can directly return the original input value.
        content
    }

    // MARK: Private

    /// The target value for which we're observing. This value is directly set once the animation starts. During animation, `animatableData` will hold the oldValue and is only updated to the target value once the animation completes.
    private var targetValue: Value

    /// The completion callback which is called once the animation completes.
    private var completion: () -> Void

    /// Verifies whether the current animation is finished and calls the completion callback if true.
    private func notifyCompletionIfFinished() {
        guard animatableData == targetValue else { return }

        /// Dispatching is needed to take the next runloop for the completion callback.
        /// This prevents errors like "Modifying state during view update, this will cause undefined behavior."
        DispatchQueue.main.async {
            self.completion()
        }
    }
}

// MARK: - AnimatableModifierDouble

struct AnimatableModifierDouble: AnimatableModifier {
    // MARK: Lifecycle

    // Re-created every time the control argument changes
    init(bindedValue: Double, completion: @escaping () -> Void) {
        self.completion = completion

        // Set animatableData to the new value. But SwiftUI again directly
        // and gradually varies the value while the body
        // is being called to animate. Following line serves the purpose of
        // associating the extenal argument with the animatableData.
        self.animatableData = bindedValue
        self.targetValue = bindedValue
        AnimatableModifierDouble.done = false
    }

    // MARK: Internal

    static var done = false

    var targetValue: Double
    var completion: () -> Void

    // SwiftUI gradually varies it from old value to the new value
    var animatableData: Double {
        didSet {
            checkIfFinished()
        }
    }

    func checkIfFinished() {
        if AnimatableModifierDouble.done { return }
        let delta = 0.1
        if animatableData > targetValue - delta &&
            animatableData < targetValue + delta {
            AnimatableModifierDouble.done = true
            DispatchQueue.main.async {
                self.completion()
            }
        }
    }

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func onAnimationCompleted(for value: Double, completion: @escaping () -> Void) -> some View {
        modifier(AnimatableModifierDouble(bindedValue: value, completion: completion))
    }
}

// MARK: - TransparentNonAnimatingFullScreenCover

#if os(iOS)

extension View {
    func transparentNonAnimatingFullScreenCover<Content: View>(
        isPresented: Binding<Bool>,
        dismissSource: DismissSource?,
        userDismissCallback: @escaping (DismissSource) -> Void,
        content: @escaping () -> Content
    ) -> some View {
        modifier(TransparentNonAnimatableFullScreenModifier(
            isPresented: isPresented,
            dismissSource: dismissSource,
            userDismissCallback: userDismissCallback,
            fullScreenContent: content
        ))
    }
}

private struct TransparentNonAnimatableFullScreenModifier<
    FullScreenContent: View
>: ViewModifier {
    @Binding
    var isPresented: Bool
    var dismissSource: DismissSource?
    var userDismissCallback: (DismissSource) -> Void
    let fullScreenContent: () -> (FullScreenContent)

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _ in
                UIView.setAnimationsEnabled(false)
            }
            .fullScreenCover(isPresented: $isPresented, content: {
                ZStack {
                    fullScreenContent()
                }
                .background(FullScreenCoverBackgroundRemovalView())
                .onAppear {
                    if !UIView.areAnimationsEnabled {
                        UIView.setAnimationsEnabled(true)
                    }
                }
                .onDisappear {
                    userDismissCallback(dismissSource ?? .binding)
                    if !UIView.areAnimationsEnabled {
                        UIView.setAnimationsEnabled(true)
                    }
                }
            })
    }
}

private struct FullScreenCoverBackgroundRemovalView: UIViewRepresentable {
    // MARK: Internal

    func makeUIView(context _: Context) -> UIView {
        BackgroundRemovalView()
    }

    func updateUIView(_: UIView, context _: Context) {}

    // MARK: Private

    private class BackgroundRemovalView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()

            superview?.superview?.backgroundColor = .clear
        }
    }
}

#endif

// MARK: - KeyboardHeightHelper

#if os(iOS)

class KeyboardHeightHelper: ObservableObject {
    // MARK: Lifecycle

    init() {
        listenForKeyboardNotifications()
    }

    // MARK: Internal

    @Published
    var keyboardHeight: CGFloat = 0
    @Published
    var keyboardDisplayed: Bool = false

    // MARK: Private

    private func listenForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let userInfo = notification.userInfo,
                  let keyboardRect =
                  userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

            self.keyboardHeight = keyboardRect.height
            self.keyboardDisplayed = true
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.keyboardHeight = 0
            self.keyboardDisplayed = false
        }
    }
}

#else

class KeyboardHeightHelper: ObservableObject {
    @Published
    var keyboardHeight: CGFloat = 0
    @Published
    var keyboardDisplayed: Bool = false
}

#endif

// MARK: - Hide keyboard

extension CGPoint {
    static var pointFarAwayFromScreen: CGPoint {
        CGPoint(x: 2 * CGSize.screenSize.width, y: 2 * CGSize.screenSize.height)
    }
}

extension CGSize {
    static var screenSize: CGSize {
        #if os(iOS) || os(tvOS)
        return UIScreen.main.bounds.size
        #elseif os(watchOS)
        return WKInterfaceDevice.current().screenBounds.size
        #elseif os(macOS)
        return NSScreen.main?.frame.size ?? .zero
        #endif
    }
}
