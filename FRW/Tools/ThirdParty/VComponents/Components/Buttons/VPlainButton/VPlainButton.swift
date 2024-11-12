//
//  VPlainButton.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 19.12.20.
//

import SwiftUI

// MARK: - VPlainButton

/// Plain button component that performs action when triggered.
///
/// Component can be initialized with content or title.
///
/// Model and state can be passed as parameters.
///
/// Usage example:
///
///     var body: some View {
///         VPlainButton(
///             action: { print("Pressed") },
///             title: "Lorem ipsum"
///         )
///     }
///
public struct VPlainButton<Content>: View where Content: View {
    // MARK: Lifecycle

    // MARK: Initializers

    /// Initializes component with action and content.
    public init(
        model: VPlainButtonModel = .init(),
        state: VPlainButtonState = .enabled,
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.model = model
        self.state = state
        self.action = action
        self.content = content
    }

    /// Initializes component with action and title.
    public init(
        model: VPlainButtonModel = .init(),
        state: VPlainButtonState = .enabled,
        action: @escaping () -> Void,
        title: String
    )
        where Content == VText {
        self.init(
            model: model,
            state: state,
            action: action,
            content: {
                VText(
                    type: .oneLine,
                    font: model.fonts.title,
                    color: model.colors.textContent.for(.default(state: state)),
                    title: title
                )
            }
        )
    }

    // MARK: Public

    // MARK: Body

    public var body: some View {
        syncInternalStateWithState()

        return VBaseButton(
            isEnabled: internalState.isEnabled,
            gesture: gestureHandler,
            content: { hitBoxButtonView }
        )
    }

    // MARK: Private

    // MARK: Properties

    private let model: VPlainButtonModel

    private let state: VPlainButtonState
    @State
    private var internalStateRaw: VPlainButtonInternalState?
    private let action: () -> Void

    private let content: () -> Content

    private var internalState: VPlainButtonInternalState {
        internalStateRaw ?? .default(state: state)
    }

    private var hitBoxButtonView: some View {
        buttonView
            .padding(.horizontal, model.layout.hitBox.horizontal)
            .padding(.vertical, model.layout.hitBox.vertical)
    }

    private var buttonView: some View {
        content()
            .opacity(model.colors.content.for(internalState))
    }

    // MARK: State Syncs

    private func syncInternalStateWithState() {
        DispatchQueue.main.async {
            if internalStateRaw == nil ||
                .init(internalState: internalState) != state {
                internalStateRaw = .default(state: state)
            }
        }
    }

    // MARK: Actions

    private func gestureHandler(gestureState: VBaseButtonGestureState) {
        internalStateRaw = .init(state: state, isPressed: gestureState.isPressed)
        if gestureState.isClicked { action() }
    }
}

// MARK: - VPlainButton_Previews

struct VPlainButton_Previews: PreviewProvider {
    static var previews: some View {
        VPlainButton(action: {}, title: "Lorem ipsum")
            .padding()
    }
}
