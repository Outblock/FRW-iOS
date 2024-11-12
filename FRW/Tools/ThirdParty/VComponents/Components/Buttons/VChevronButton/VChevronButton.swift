//
//  VChevronButton.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 12/22/20.
//

import SwiftUI

// MARK: - VChevronButton

/// Circular colored chevron button component that performs action when triggered.
///
/// Model and state can be passed as parameters.
///
/// Usage example:
///
///     @State var direction: VChevronButtonDirection = .left
///
///     var body: some View {
///         VChevronButton(direction: direction, action: {
///             print("Pressed")
///         })
///     }
///
public struct VChevronButton: View {
    // MARK: Lifecycle

    // MARK: Initializers

    /// Initializes component with direction and action.
    public init(
        model: VChevronButtonModel = .init(),
        direction: VChevronButtonDirection,
        state: VChevronButtonState = .enabled,
        action: @escaping () -> Void
    ) {
        self.model = model
        self.direction = direction
        self.state = state
        self.action = action
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

    private let model: VChevronButtonModel

    private let direction: VChevronButtonDirection

    private let state: VChevronButtonState
    @State
    private var internalStateRaw: VChevronButtonInternalState?
    private let action: () -> Void

    private var internalState: VChevronButtonInternalState {
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
    }

    private var buttonContent: some View {
        ImageBook.chevronUp
            .resizable()
            .frame(dimension: model.layout.iconDimension)
            .foregroundColor(model.colors.content.for(internalState))
            .opacity(model.colors.content.for(internalState))
            .rotationEffect(.init(degrees: direction.angle))
            .ifLet(
                model.layout.navigationBarBackButtonOffsetX,
                transform: { $0.offset(x: $1, y: 0) }
            )
    }

    private var backgroundView: some View {
        Circle()
            .foregroundColor(model.colors.background.for(internalState))
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

// MARK: - Rotation

extension VChevronButtonDirection {
    fileprivate var angle: Double {
        switch self {
        case .up: return 0
        case .right: return 90
        case .down: return 180
        case .left: return -90
        }
    }
}

// MARK: - VChevronButton_Previews

struct VChevronButton_Previews: PreviewProvider {
    static var previews: some View {
        VChevronButton(direction: .right, action: {})
            .padding()
    }
}
