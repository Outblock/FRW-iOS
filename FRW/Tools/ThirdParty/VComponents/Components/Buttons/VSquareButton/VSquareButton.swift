//
//  VSquareButton.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 19.12.20.
//

import SwiftUI

// MARK: - VSquareButton

/// Squared colored button component that performs action when triggered.
///
/// Component can be initialized with content or title.
///
/// Model and state can be passed as parameters.
///
/// Usage example:
///
///     var body: some View {
///         VSquareButton(action: { print("Pressed") }, content: {
///             Image(systemName: "swift")
///                 .resizable()
///                 .frame(width: 20, height: 20)
///                 .foregroundColor(.white)
///         })
///     }
///
public struct VSquareButton<Content>: View where Content: View {
    // MARK: Lifecycle

    // MARK: Initializers

    /// Initializes component with action and content.
    public init(
        model: VSquareButtonModel = .init(),
        state: VSquareButtonState = .enabled,
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
        model: VSquareButtonModel = .init(),
        state: VSquareButtonState = .enabled,
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

    private let model: VSquareButtonModel

    private let state: VSquareButtonState
    @State
    private var internalStateRaw: VSquareButtonInternalState?
    private let action: () -> Void

    private let content: () -> Content

    private var internalState: VSquareButtonInternalState {
        internalStateRaw ?? .default(state: state)
    }

    private var hitBoxButtonView: some View {
        buttonView
            .padding(.horizontal, model.layout.hitBox.horizontal)
            .padding(.vertical, model.layout.hitBox.vertical)
    }

    private var buttonView: some View {
        buttonContent
            .frame(dimension: model.layout.dimension)
            .background(backgroundView)
            .overlay(border)
    }

    private var buttonContent: some View {
        content()
            .padding(.horizontal, model.layout.contentMargins.horizontal)
            .padding(.vertical, model.layout.contentMargins.vertical)
            .opacity(model.colors.content.for(internalState))
    }

    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: model.layout.cornerRadius)
            .foregroundColor(model.colors.background.for(internalState))
    }

    @ViewBuilder
    private var border: some View {
        if model.layout.hasBorder {
            RoundedRectangle(cornerRadius: model.layout.cornerRadius)
                .strokeBorder(
                    model.colors.border.for(internalState),
                    lineWidth: model.layout.borderWidth
                )
        }
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

// MARK: - VSquareButton_Previews

struct VSquareButton_Previews: PreviewProvider {
    static var previews: some View {
        VSquareButton(action: {}, content: {
            Image(systemName: "swift")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.white)
        })
    }
}
