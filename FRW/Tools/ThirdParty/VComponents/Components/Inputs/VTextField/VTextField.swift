//
//  VTextField.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/19/21.
//

import SwiftUI

// MARK: - VTextField

/// Input component that displays an editable text interface.
///
/// Model, type, highlight, palceholder, header, footer, and event callbacks can be passed as parameters.
///
/// By default, component type is `standard`.
/// If `secure` type is used, visiblity button would replace clear button. When textfield is secure, clear and cancel buttons are not visible.
/// If `search` type is used, a magnification glass icon would appear on the left.
///
/// It is possible to override actions of return, clear, and cancel buttons by passing them as a parameter.
///
/// Usage example:
///
///     @State var text: String = "Lorem ipsum"
///
///     var body: some View {
///         VTextField(
///             placeholder: "Lorem ipsum",
///             headerTitle: "Lorem ipsum dolor sit amet",
///             footerTitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
///             text: $text
///         )
///             .padding()
///     }
///
/// Textfield can also be focused externally by passing state:
///
///     @State var state: VTextFieldState = .focused
///     @State var text: String = "Lorem ipsum"
///
///     var body: some View {
///         VTextField(
///             state: $state,
///             placeholder: "Lorem ipsum",
///             headerTitle: "Lorem ipsum dolor sit amet",
///             footerTitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
///             text: $text
///         )
///             .padding()
///     }
///
/// Full use of overriden actions and event callbacks:
///
///     let model: VTextFieldModel = {
///         var model: VTextFieldModel = .init()
///
///         model.misc.returnButton = .default
///         model.misc.clearButton = true
///         model.misc.cancelButton = "Cancel"
///
///         return model
///     }()
///
///     @State var text: String = "Lorem ipsum"
///
///     var body: some View {
///         VTextField(
///             model: model,
///             placeholder: "Lorem ipsum",
///             headerTitle: "Lorem ipsum dolor sit amet",
///             footerTitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
///             text: $text,
///             onBegin: { print("Editing Began") },
///             onChange: { print("Editing Changed") },
///             onEnd: { print("Editing Ended") },
///             onReturn: .returnAndCustom({ print("Returned and ...") }),
///             onClear: .clearAndCustom({ print("Cleared and ...") }),
///             onCancel: .clearAndCustom({ print("Cancelled and ...") })
///         )
///             .padding()
///     }
///
/// `Secure` textfield:
///
///     @State var text: String = "Lorem ipsum"
///
///     var body: some View {
///         VTextField(
///             type: .secure,
///             placeholder: "Lorem ipsum",
///             headerTitle: "Lorem ipsum dolor sit amet",
///             footerTitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
///             text: $text
///         )
///             .padding()
///     }
///
/// `Search` textfield:
///
///     @State var text: String = "Lorem ipsum"
///
///     var body: some View {
///         VTextField(
///             type: .search,
///             placeholder: "Lorem ipsum",
///             headerTitle: "Lorem ipsum dolor sit amet",
///             footerTitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
///             text: $text
///         )
///             .padding()
///     }
///
public struct VTextField: View {
    // MARK: Lifecycle

    // MARK: Initialiers

    /// Initializes component with state and text.
    public init(
        model: VTextFieldModel = .init(),
        type textFieldType: VTextFieldType = .default,
        state: Binding<VTextFieldState>,
        highlight: VTextFieldHighlight = .default,
        placeholder: String? = nil,
        headerTitle: String? = nil,
        footerTitle: String? = nil,
        text: Binding<String>,
        onBegin beginHandler: (() -> Void)? = nil,
        onChange changeHandler: (() -> Void)? = nil,
        onEnd endHandler: (() -> Void)? = nil,
        onReturn returnButtonAction: VTextFieldReturnButtonAction = .default,
        onClear clearButtonAction: VTextFieldClearButtonAction = .default,
        onCancel cancelButtonAction: VTextFieldCancelButtonAction = .default
    ) {
        self.model = model
        self.textFieldType = textFieldType
        _stateExternally = state
        self.stateManagament = .external
        self.highlight = highlight
        self.placeholder = placeholder
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
        _text = text
        self.beginHandler = beginHandler
        self.changeHandler = changeHandler
        self.endHandler = endHandler
        self.returnButtonAction = returnButtonAction
        self.clearButtonAction = clearButtonAction
        self.cancelButtonAction = cancelButtonAction
    }

    /// Initializes component with text.
    public init(
        model: VTextFieldModel = .init(),
        type textFieldType: VTextFieldType = .default,
        highlight: VTextFieldHighlight = .default,
        placeholder: String? = nil,
        headerTitle: String? = nil,
        footerTitle: String? = nil,
        text: Binding<String>,
        onBegin beginHandler: (() -> Void)? = nil,
        onChange changeHandler: (() -> Void)? = nil,
        onEnd endHandler: (() -> Void)? = nil,
        onReturn returnButtonAction: VTextFieldReturnButtonAction = .default,
        onClear clearButtonAction: VTextFieldClearButtonAction = .default,
        onCancel cancelButtonAction: VTextFieldCancelButtonAction = .default
    ) {
        self.model = model
        self.textFieldType = textFieldType
        _stateExternally = .constant(.enabled)
        self.stateManagament = .internal
        self.highlight = highlight
        self.placeholder = placeholder
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
        _text = text
        self.beginHandler = beginHandler
        self.changeHandler = changeHandler
        self.endHandler = endHandler
        self.returnButtonAction = returnButtonAction
        self.clearButtonAction = clearButtonAction
        self.cancelButtonAction = cancelButtonAction
    }

    // MARK: Public

    // MARK: Body

    public var body: some View {
        syncInternalStateWithState()

        return VStack(alignment: .leading, spacing: model.layout.headerFooterSpacing, content: {
            headerView
            textFieldView
            footerView
        })
    }

    // MARK: Private

    private let model: VTextFieldModel
    private let textFieldType: VTextFieldType

    @State
    private var stateInternally: VTextFieldState = .enabled
    @Binding
    private var stateExternally: VTextFieldState
    private let stateManagament: ComponentStateManagement
    private let highlight: VTextFieldHighlight

    private let placeholder: String?
    private let headerTitle: String?
    private let footerTitle: String?
    @Binding
    private var text: String

    private let beginHandler: (() -> Void)?
    private let changeHandler: (() -> Void)?
    private let endHandler: (() -> Void)?

    private let returnButtonAction: VTextFieldReturnButtonAction
    private let clearButtonAction: VTextFieldClearButtonAction
    private let cancelButtonAction: VTextFieldCancelButtonAction

    @State
    private var isTextNonEmpty: Bool = false
    @State
    private var secureFieldIsVisible: Bool = false

    private var state: Binding<VTextFieldState> {
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

    private var textFieldView: some View {
        HStack(spacing: model.layout.contentSpacing, content: {
            HStack(spacing: model.layout.contentSpacing, content: {
                searchIcon
                textFieldContentView
                clearButton
                visibilityButton
            })
            .padding(.horizontal, model.layout.contentMarginHorizontal)
            .frame(height: model.layout.height)
            .background(background)

            cancelButton
        })
        .frame(height: model.layout.height)
    }

    @ViewBuilder
    private var headerView: some View {
        if let headerTitle = headerTitle, !headerTitle.isEmpty {
            VText(
                type: .oneLine,
                font: model.fonts.header,
                color: model.colors.header.for(state.wrappedValue, highlight: highlight),
                title: headerTitle
            )
            .padding(.horizontal, model.layout.headerFooterMarginHorizontal)
            .opacity(model.colors.content.for(state.wrappedValue))
        }
    }

    @ViewBuilder
    private var footerView: some View {
        if let footerTitle = footerTitle, !footerTitle.isEmpty {
            HStack {
                switch highlight {
                case .none:
                    EmptyView()
                case .success:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(model.colors.footer.for(
                            state.wrappedValue,
                            highlight: highlight
                        ))
                case .error:
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(model.colors.footer.for(
                            state.wrappedValue,
                            highlight: highlight
                        ))
                case .loading:
                    VSpinner(type: .continous(SpinnerStyle.primary))
                }

                VText(
                    type: .multiLine(limit: nil, alignment: .leading),
                    font: model.fonts.footer,
                    color: model.colors.footer.for(state.wrappedValue, highlight: highlight),
                    title: footerTitle
                )
            }
            .padding(.horizontal, model.layout.headerFooterMarginHorizontal)
            .opacity(model.colors.content.for(state.wrappedValue))
        }
    }

    @ViewBuilder
    private var searchIcon: some View {
        if textFieldType.isSearch {
            ImageBook.search
                .resizable()
                .frame(dimension: model.layout.searchIconDimension)
                .foregroundColor(model.colors.searchIcon.for(
                    state.wrappedValue,
                    highlight: highlight
                ))
                .opacity(model.colors.content.for(state.wrappedValue))
        }

        if textFieldType.isUserName {
            RoundedRectangle(cornerRadius: 12)
                .aspectRatio(1, contentMode: .fit)
                .height(model.layout.height - 20)
                .foregroundColor(Color.Theme.Accent.green)
                .overlay {
                    Text("@")
                        .font(.title)
                        .foregroundColor(.white)
                        .baselineOffset(4)
                }
        }
    }

    private var textFieldContentView: some View {
        UIKitTextFieldRepresentable(
            model: model.baseTextFieldSubModel(
                state: state.wrappedValue,
                isSecureTextEntry: textFieldType.isSecure && !secureFieldIsVisible
            ),
            state: VTextFieldState.baseTextFieldState(state),
            placeholder: placeholder,
            text: $text,
            onBegin: beginHandler,
            onChange: changeHandler,
            onEnd: endHandler,
            onReturn: returnButtonAction
        )
        .onChange(of: text, perform: textChanged)
    }

    @ViewBuilder
    private var clearButton: some View {
        if !textFieldType.isSecure && isTextNonEmpty && model.misc.clearButton {
            VCloseButton(
                model: model.clearSubButtonModel(state: state.wrappedValue, highlight: highlight),
                state: state.wrappedValue.clearButtonState,
                action: runClearAction
            )
        }
    }

    @ViewBuilder
    private var visibilityButton: some View {
        if textFieldType.isSecure {
            VSquareButton(
                model: model.visibilityButtonSubModel(
                    state: state.wrappedValue,
                    highlight: highlight
                ),
                state: state.wrappedValue.visiblityButtonState,
                action: { secureFieldIsVisible.toggle() },
                content: {
                    visiblityIcon
                        .resizable()
                        .frame(dimension: model.layout.visibilityButtonIconDimension)
                        .foregroundColor(model.colors.visibilityButtonIcon.for(
                            state.wrappedValue,
                            highlight: highlight
                        ))
                }
            )
        }
    }

    @ViewBuilder
    private var cancelButton: some View {
        if !textFieldType.isSecure, isTextNonEmpty, state.wrappedValue.isFocused,
           let cancelButton = model.misc.cancelButton, !cancelButton.isEmpty {
            VPlainButton(
                model: model.cancelButtonSubModel,
                state: state.wrappedValue.cancelButtonState,
                action: runCancelAction,
                title: cancelButton
            )
        }
    }

    private var background: some View {
        ZStack(content: {
            RoundedRectangle(cornerRadius: model.layout.cornerRadius)
                .foregroundColor(model.colors.background.for(
                    state.wrappedValue,
                    highlight: highlight
                ))

            RoundedRectangle(cornerRadius: model.layout.cornerRadius)
                .strokeBorder(
                    model.colors.border.for(state.wrappedValue, highlight: highlight),
                    lineWidth: model.layout.borderWidth
                )
        })
    }

    // MARK: Visiblity Icon

    private var visiblityIcon: Image {
        switch secureFieldIsVisible {
        case false: return ImageBook.visibilityOff
        case true: return ImageBook.visibilityOn
        }
    }

    // MARK: State Syncs

    private func syncInternalStateWithState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + model.animations.delayToAnimateButtons) {
            isTextNonEmpty = !text.isEmpty
        }

        DispatchQueue.main.async {
            if secureFieldIsVisible, !textFieldType.isSecure { secureFieldIsVisible = false }
        }
    }

    // MARK: Actions

    private func textChanged(_ text: String) {
        withAnimation(model.animations.buttonsAppearDisappear) { isTextNonEmpty = !text.isEmpty }
    }

    private func runClearAction() {
        switch clearButtonAction {
        case .clear: zeroText()
        case let .custom(action): action()
        case let .clearAndCustom(action): zeroText(); action()
        }
    }

    private func runCancelAction() {
        switch cancelButtonAction {
        case .clear: zeroText()
        case let .custom(action): action()
        case let .clearAndCustom(action): zeroText(); action()
        }
    }

    private func zeroText() {
        text = ""
        withAnimation(model.animations.buttonsAppearDisappear) { isTextNonEmpty = false }
    }
}

// MARK: - VTextField_Previews

struct VTextField_Previews: PreviewProvider {
    // MARK: Internal

    static var previews: some View {
        VStack(spacing: 50, content: {
            ForEach(VTextFieldType.allCases, id: \.self, content: { type in
                VTextField(
                    type: type,
                    state: $state,
                    placeholder: "Lorem ipsum",
                    headerTitle: "Lorem ipsum dolor sit amet",
                    footerTitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
                    text: $text
                )
            })
        })
        .padding()
    }

    // MARK: Private

    @State
    private static var state: VTextFieldState = .enabled
    @State
    private static var text: String = "Lorem ipsum"
}
