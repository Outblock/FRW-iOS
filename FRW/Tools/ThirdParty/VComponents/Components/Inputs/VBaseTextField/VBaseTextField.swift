//
//  VBaseTextField.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/19/21.
//

import SwiftUI

// MARK: - VBaseTextField

/// Core component that is used throughout the library as textfield.
///
/// Model, state, placeholder, event callbacks, and button action can be passed as parameters.
///
/// It is possible to override action of return button by passing it as a parameter.
///
/// If two TextField's state is managed by a single property, unpredictable behaviors would occur.
///
/// Usage example:
///
///     @State var text: String = "Lorem ipsum"
///
///     var body: some View {
///         VBaseTextField(
///             placeholder: "Lorem ipsum",
///             text: $text
///         )
///             .padding()
///     }
///
/// Textfield can also be focused externally by passing state:
///
///     @State var state: VBaseTextFieldState = .focused
///     @State var text: String = "Lorem ipsum"
///
///     var body: some View {
///         VBaseTextField(
///             state: $state,
///             placeholder: "Lorem ipsum",
///             text: $text
///         )
///             .padding()
///     }
///
/// Full use of overriden action and event callbacks:
///
///     @State var text: String = "Lorem ipsum"
///
///     var body: some View {
///         VBaseTextField(
///             placeholder: "Lorem ipsum",
///             text: $text,
///             onBegin: { print("Editing Began") },
///             onChange: {  print("Editing Changed") },
///             onEnd: { print("Editing Ended") },
///             onReturn: .returnAndCustom({ print("Returned and ...") })
///         )
///             .padding()
///     }
///
public struct VBaseTextField: View {
    // MARK: Lifecycle

    // MARK: Initialiers

    /// Initializes component with state and text.
    public init(
        model: VBaseTextFieldModel = .init(),
        state: Binding<VBaseTextFieldState>,
        placeholder: String? = nil,
        text: Binding<String>,
        onBegin beginHandler: (() -> Void)? = nil,
        onChange changeHandler: (() -> Void)? = nil,
        onEnd endHandler: (() -> Void)? = nil,
        onReturn returnAction: VBaseTextFieldReturnButtonAction = .default
    ) {
        self.model = model
        _stateExternally = state
        self.stateManagament = .external
        self.placeholder = placeholder
        _text = text
        self.beginHandler = beginHandler
        self.changeHandler = changeHandler
        self.endHandler = endHandler
        self.returnAction = returnAction
    }

    /// Initializes component with text.
    public init(
        model: VBaseTextFieldModel = .init(),
        placeholder: String? = nil,
        text: Binding<String>,
        onBegin beginHandler: (() -> Void)? = nil,
        onChange changeHandler: (() -> Void)? = nil,
        onEnd endHandler: (() -> Void)? = nil,
        onReturn returnAction: VBaseTextFieldReturnButtonAction = .default
    ) {
        self.model = model
        _stateExternally = .constant(.enabled)
        self.stateManagament = .internal
        self.placeholder = placeholder
        _text = text
        self.beginHandler = beginHandler
        self.changeHandler = changeHandler
        self.endHandler = endHandler
        self.returnAction = returnAction
    }

    // MARK: Public

    // MARK: Body

    public var body: some View {
        UIKitTextFieldRepresentable(
            model: model,
            state: state,
            placeholder: placeholder,
            text: $text,
            onBegin: beginHandler,
            onChange: changeHandler,
            onEnd: endHandler,
            onReturn: returnAction
        )
    }

    // MARK: Private

    private let model: VBaseTextFieldModel

    @State
    private var stateInternally: VBaseTextFieldState = .enabled
    @Binding
    private var stateExternally: VBaseTextFieldState
    private let stateManagament: ComponentStateManagement
    private let placeholder: String?
    @Binding
    private var text: String

    private let beginHandler: (() -> Void)?
    private let changeHandler: (() -> Void)?
    private let endHandler: (() -> Void)?

    private let returnAction: VBaseTextFieldReturnButtonAction

    private var state: Binding<VBaseTextFieldState> {
        .init(
            get: {
                switch stateManagament {
                case .internal: return stateInternally
                case .external: return stateExternally
                }
            },
            set: { value in
                switch stateManagament {
                case .internal: stateInternally = value
                case .external: stateExternally = value
                }
            }
        )
    }
}

// MARK: - VBaseTextField_Previews

struct VBaseTextField_Previews: PreviewProvider {
    // MARK: Internal

    static var previews: some View {
        VBaseTextField(
            state: $state,
            placeholder: "Lorem ipsum",
            text: $text
        )
        .padding()
    }

    // MARK: Private

    @State
    private static var state: VBaseTextFieldState = .enabled
    @State
    private static var text: String = "Lorem ipsum"
}
