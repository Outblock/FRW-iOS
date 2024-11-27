//
//  VRadioButton.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/19/21.
//

import SwiftUI

// MARK: - VRadioButton

/// State picker component that toggles between off, on, or disabled states, and displays content.
///
/// Component can be initialized with content, title, or without body. `Bool` can also be passed as state.
/// Component can aslo be placed inside a Radio Group, in which case component is initialized with `VPickableItem` or `VPickableTitledItem`.
///
/// Model can be passed as parameter.
///
/// Usage example:
///
///     @State var state: VRadioButtonState = .on
///
///     var body: some View {
///         VRadioButton(
///             state: $state,
///             title: "Lorem ipsum"
///         )
///     }
///
/// Component placed inside a Radio Group:
///
///     enum Gender: Int, Identifiable, VPickableTitledItem {
///         case male, female, other
///
///         var id: Int { rawValue }
///
///         var pickerTitle: String {
///             switch self {
///             case .male: return "Male"
///             case .female: return "Female"
///             case .other: return "Other"
///             }
///         }
///     }
///
///     @State var selection: Gender = .male
///
///     var body: some View {
///         VStack(alignment: .leading, content: {
///             ForEach(Gender.allCases, content: { gender in
///                 VRadioButton(selection: $selection, selects: gender)
///             })
///         })
///     }
///
public struct VRadioButton<Content>: View where Content: View {
    // MARK: Lifecycle

    // MARK: Initializers - State

    /// Initializes component with state and content.
    public init(
        model: VRadioButtonModel = .init(),
        state: Binding<VRadioButtonState>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.model = model
        _state = state
        self.content = content
    }

    /// Initializes component with state and title.
    public init(
        model: VRadioButtonModel = .init(),
        state: Binding<VRadioButtonState>,
        title: String
    )
        where Content == VText {
        self.init(
            model: model,
            state: state,
            content: {
                VText(
                    type: .multiLine(limit: nil, alignment: .leading),
                    font: model.fonts.title,
                    color: model.colors.textContent.for(.init(
                        state: state.wrappedValue,
                        isPressed: false
                    )),
                    title: title
                )
            }
        )
    }

    /// Initializes component with state.
    public init(
        model: VRadioButtonModel = .init(),
        state: Binding<VRadioButtonState>
    )
        where Content == Never {
        self.model = model
        _state = state
        self.content = nil
    }

    // MARK: Initializers - Bool

    /// Initializes component with bool and content.
    public init(
        model: VRadioButtonModel = .init(),
        isOn: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            model: model,
            state: Binding<VRadioButtonState>(bool: isOn),
            content: content
        )
    }

    /// Initializes component with bool and title.
    public init(
        model: VRadioButtonModel = .init(),
        isOn: Binding<Bool>,
        title: String
    )
        where Content == VText {
        self.init(
            model: model,
            state: .init(bool: isOn),
            content: {
                VText(
                    type: .multiLine(limit: nil, alignment: .leading),
                    font: model.fonts.title,
                    color: model.colors.textContent.for(VRadioButtonInternalState(
                        bool: isOn.wrappedValue,
                        isPressed: false
                    )),
                    title: title
                )
            }
        )
    }

    /// Initializes component with bool.
    public init(
        model: VRadioButtonModel = .init(),
        isOn: Binding<Bool>
    )
        where Content == Never {
        self.model = model
        _state = .init(bool: isOn)
        self.content = nil
    }

    // MARK: Initializers - Pickable Item

    /// Initializes component with `VPickableItem` and content.
    public init<Item>(
        model: VRadioButtonModel = .init(),
        selection: Binding<Item>,
        selects selectingValue: Item,
        @ViewBuilder content: @escaping () -> Content
    )
        where Item: VPickableItem {
        self.init(
            model: model,
            state: Binding<VRadioButtonState>(
                get: { selection.wrappedValue == selectingValue ? .on : .off },
                set: { if $0.isOn { selection.wrappedValue = selectingValue } }
            ),
            content: content
        )
    }

    /// Initializes component with `VPickableItem`.
    public init<Item>(
        model: VRadioButtonModel = .init(),
        selection: Binding<Item>,
        selects selectingValue: Item
    )
        where
        Content == Never,
        Item: VPickableItem {
        self.init(
            model: model,
            state: Binding<VRadioButtonState>(
                get: { selection.wrappedValue == selectingValue ? .on : .off },
                set: { if $0.isOn { selection.wrappedValue = selectingValue } }
            )
        )
    }

    // MARK: Initializers - Pickable Titled Item

    /// Initializes component with `VPickableTitledItem` and content.
    public init<Item>(
        model: VRadioButtonModel = .init(),
        selection: Binding<Item>,
        selects selectingValue: Item
    )
        where
        Content == VText,
        Item: VPickableTitledItem {
        self.init(
            model: model,
            state: Binding<VRadioButtonState>(
                get: { selection.wrappedValue == selectingValue ? .on : .off },
                set: { if $0.isOn { selection.wrappedValue = selectingValue } }
            ),
            content: {
                VText(
                    type: .multiLine(limit: nil, alignment: .leading),
                    font: model.fonts.title,
                    color: model.colors.textContent.for(VRadioButtonInternalState(
                        bool: selection.wrappedValue == selectingValue,
                        isPressed: false
                    )),
                    title: selectingValue.pickerTitle
                )
            }
        )
    }

    // MARK: Public

    // MARK: Body

    public var body: some View {
        syncInternalStateWithState()

        return Group(content: {
            switch content {
            case nil:
                radioButton

            case let content?:
                HStack(spacing: 0, content: {
                    radioButton
                    spacerView
                    contentView(content: content)
                })
            }
        })
    }

    // MARK: Private

    // MARK: Properties

    private let model: VRadioButtonModel

    @Binding
    private var state: VRadioButtonState
    @State
    private var internalStateRaw: VRadioButtonInternalState?
    private let content: (() -> Content)?

    private var internalState: VRadioButtonInternalState {
        internalStateRaw ?? .default(state: state)
    }

    private var contentIsEnabled: Bool { internalState.isEnabled && model.misc.contentIsClickable }

    private var radioButton: some View {
        VBaseButton(
            isEnabled: internalState.isEnabled,
            gesture: gestureHandler,
            content: {
                ZStack(content: {
                    Circle()
                        .frame(dimension: model.layout.dimension)
                        .foregroundColor(model.colors.fill.for(internalState))

                    Circle()
                        .strokeBorder(
                            model.colors.border.for(internalState),
                            lineWidth: model.layout.borderWith
                        )
                        .frame(dimension: model.layout.dimension)

                    Circle()
                        .frame(dimension: model.layout.bulletDimension)
                        .foregroundColor(model.colors.bullet.for(internalState))
                })
                .frame(dimension: model.layout.dimension)
                .padding(model.layout.hitBox)
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
            if internalStateRaw == nil ||
                .init(internalState: internalState) != state {
                withAnimation(model.animations.stateChange) {
                    internalStateRaw = .default(state: state)
                }
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
}

// MARK: - VRadioButton_Previews

struct VRadioButton_Previews: PreviewProvider {
    // MARK: Internal

    static var previews: some View {
        VRadioButton(state: $state, title: "Lorem ipsum")
    }

    // MARK: Private

    @State
    private static var state: VRadioButtonState = .on
}
