//
//  VToggle.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 19.12.20.
//

import SwiftUI

// MARK: - V Toggle

/// State picker component that toggles between off, on, or disabled states, and displays content.
///
/// Component can be initialized with content, title, or without body. `Bool` can also be passed as state.
///
/// Model can be passed as parameter.
///
/// Usage example:
///
///     @State var state: VToggleState = .on
///
///     var body: some View {
///         VToggle(
///             state: $state,
///             title: "Lorem ipsum"
///         )
///     }
///
public struct VToggle<Content>: View where Content: View {
    // MARK: Properties

    private let model: VToggleModel

    @Binding private var state: VToggleState
    @State private var internalStateRaw: VToggleInternalState?
    private var internalState: VToggleInternalState { internalStateRaw ?? .default(state: state) }

    private let content: (() -> Content)?

    private var contentIsEnabled: Bool { internalState.isEnabled && model.misc.contentIsClickable }

    // MARK: Initializers - State

    /// Initializes component with state and content.
    public init(
        model: VToggleModel = .init(),
        state: Binding<VToggleState>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.model = model
        _state = state
        self.content = content
    }

    /// Initializes component with state and title.
    public init(
        model: VToggleModel = .init(),
        state: Binding<VToggleState>,
        title: String
    )
        where Content == VText
    {
        self.init(
            model: model,
            state: state,
            content: {
                VText(
                    type: .multiLine(limit: nil, alignment: .leading),
                    font: model.fonts.title,
                    color: model.colors.textContent.for(.init(state: state.wrappedValue, isPressed: false)),
                    title: title
                )
            }
        )
    }

    /// Initializes component with state.
    public init(
        model: VToggleModel = .init(),
        state: Binding<VToggleState>
    )
        where Content == Never
    {
        self.model = model
        _state = state
        content = nil
    }

    // MARK: Initializers - Bool

    /// Initializes component with bool and content.
    public init(
        model: VToggleModel = .init(),
        isOn: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            model: model,
            state: Binding<VToggleState>(bool: isOn),
            content: content
        )
    }

    /// Initializes component with bool and title.
    public init(
        model: VToggleModel = .init(),
        isOn: Binding<Bool>,
        title: String
    )
        where Content == VText
    {
        self.init(
            model: model,
            state: .init(bool: isOn),
            content: {
                VText(
                    type: .multiLine(limit: nil, alignment: .leading),
                    font: model.fonts.title,
                    color: model.colors.textContent.for(VRadioButtonInternalState(bool: isOn.wrappedValue, isPressed: false)),
                    title: title
                )
            }
        )
    }

    /// Initializes component with bool.
    public init(
        model: VToggleModel = .init(),
        isOn: Binding<Bool>
    )
        where Content == Never
    {
        self.model = model
        _state = .init(bool: isOn)
        content = nil
    }

    // MARK: Body

    public var body: some View {
        syncInternalStateWithState()

        return Group(content: {
            switch content {
            case nil:
                toggle

            case let content?:
                HStack(spacing: 0, content: {
                    toggle
                    spacerView
                    contentView(content: content)
                })
            }
        })
    }

    private var toggle: some View {
        VBaseButton(
            isEnabled: internalState.isEnabled,
            gesture: gestureHandler,
            content: {
                ZStack(content: {
                    RoundedRectangle(cornerRadius: model.layout.cornerRadius)
                        .foregroundColor(model.colors.fill.for(internalState))

                    Circle()
                        .frame(dimension: model.layout.thumbDimension)
                        .foregroundColor(model.colors.thumb.for(internalState))
                        .offset(x: thumbOffset)
                })
                .frame(size: model.layout.size)
            }
        )
    }

    private var spacerView: some View {
        VBaseButton(
            isEnabled: contentIsEnabled,
            gesture: gestureHandler,
            content: {
                Rectangle()
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: model.layout.contentMarginLeading)
                    .foregroundColor(.clear)
            }
        )
    }

    private func contentView(
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VBaseButton(
            isEnabled: contentIsEnabled,
            gesture: gestureHandler,
            content: {
                content()
                    .opacity(model.colors.content.for(internalState))
            }
        )
    }

    // MARK: State Syncs

    private func syncInternalStateWithState() {
        DispatchQueue.main.async {
            if
                internalStateRaw == nil ||
                .init(internalState: internalState) != state
            {
                withAnimation(model.animations.stateChange) { internalStateRaw = .default(state: state) }
            }
        }
    }

    // MARK: Actions

    private func gestureHandler(gestureState: VBaseButtonGestureState) {
        switch gestureState.isClicked {
        case false:
            internalStateRaw = .init(state: state, isPressed: gestureState.isPressed)

        case true:
            state.setNextState()
            withAnimation(model.animations.stateChange) { internalStateRaw?.setNextState() }
        }
    }

    // MARK: Thumb Position

    private var thumbOffset: CGFloat {
        let offset: CGFloat = model.layout.animationOffset

        switch internalState {
        case .off: return -offset
        case .on: return offset
        case .pressedOff: return -offset
        case .pressedOn: return offset
        case .disabled: return -offset
        }
    }
}

// MARK: - Preview

struct VToggle_Previews: PreviewProvider {
    @State private static var state: VToggleState = .on

    static var previews: some View {
        VToggle(state: $state, title: "Lorem ipsum")
    }
}
