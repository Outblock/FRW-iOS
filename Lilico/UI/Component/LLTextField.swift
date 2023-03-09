//
//  LLTextField.swift
//  Lilico
//
//  Created by Hao Fu on 26/12/21.
//

import SwiftUI
import SwiftUIX

final class LL {}

extension LL {
    struct TextField: View {
        public enum Status {
            case normal
            case loading(String = "Loading")
            case success(String = "Success")
            case error(String = "Error")
        }

        public enum Style {
            case normal
            case secure
        }

        public struct Delegate {
            var onEditingChanged: (Bool) -> Void
            var onCommit: () -> Void

            init(onEditingChanged: @escaping (Bool) -> Void = { _ in },
                 onCommit: @escaping () -> Void = {})
            {
                self.onCommit = onCommit
                self.onEditingChanged = onEditingChanged
            }
        }

        var placeHolder: String

        @Binding
        var style: Style

        var onEditingChanged: BoolBlock?

        var onCommit: VoidBlock?

        @Binding
        var text: String

        var status: Status

        @FocusState
        var focusState: Bool

        var statusColor: Color {
            switch status {
            case .normal, .loading:
                return focusState ? .black : .gray
            case .success:
                return .green
            case .error:
                return .red
            }
        }

        var body: some View {
            HStack {
                switch style {
                case .secure:
                    SwiftUI.SecureField(placeHolder,
                                        text: $text,
                                        onCommit: onCommit ?? {})
                        .onChange(of: text, perform: { _ in
                            if let block = onEditingChanged {
                                block(true)
                            }
                        })
                        .focused($focusState)
                        .padding()
                case .normal:
                    SwiftUI
                        .TextField(placeHolder,
                                   text: $text,
                                   onEditingChanged: onEditingChanged ?? { _ in },
                                   onCommit: onCommit ?? {})
                        .focused($focusState)
                        .padding()
                }

                HStack(spacing: 5) {
                    switch self.status {
                    case .normal:
                        EmptyView()
                    case let .success(message):
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(message)
                            .foregroundColor(.secondary)
                    case let .error(message):
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.red)
                        Text(message)
                            .foregroundColor(.secondary)
                    case let .loading(message):
                        ProgressView()
                        Text(message)
                            .foregroundColor(.secondary)
                    }
                }
                .font(.footnote)
                .padding(.horizontal, 10)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(statusColor, lineWidth: 0.5)
            }
        }

        init(placeHolder: String = "",
             text: Binding<String>,
             status: LL.TextField.Status = .normal,
             style: Binding<LL.TextField.Style> = .constant(.normal),
             onEditingChanged: BoolBlock? = nil,
             onCommit: VoidBlock? = nil)
        {
            self.placeHolder = placeHolder
            self.status = status
            _text = text
            _style = style
            self.onEditingChanged = onEditingChanged
            self.onCommit = onCommit
        }
    }
}

struct LLTextField_Previews: PreviewProvider {
    @State
    private static var normalStatus: LL.TextField.Status = .normal

    @State
    private static var errorStatus: LL.TextField.Status = .error("It's taken")

    @State
    private static var successStatus: LL.TextField.Status = .success("Sounds good")

    @State
    private static var loadingStatus: LL.TextField.Status = .loading("Loading")

    @State
    private static var text: String = ""

    private static var delegate = LL.TextField.Delegate()

    static var previews: some View {
        VStack(spacing: 50) {}
//            LL.TextField(placeHolder: "Test",
//                         text: $text,
//                         status: $normalStatus)
//            LL.TextField(placeHolder: "Test", text: $text, status: $successStatus)
//            LL.TextField(placeHolder: "Test", text: $text, status: $errorStatus)
//            LL.TextField(placeHolder: "Test", text: $text, status: $loadingStatus)
//        }
//        .previewLayout(.sizeThatFits)
//        .padding()
//
//        VStack(spacing: 50) {
//            LL.TextField(placeHolder: "Test", text: $text, status: $normalStatus)
//            LL.TextField(placeHolder: "Test", text: $text, status: $successStatus)
//            LL.TextField(placeHolder: "Test", text: $text, status: $errorStatus)
//            LL.TextField(placeHolder: "Test", text: $text, status: $loadingStatus)
//        }
//        .previewLayout(.sizeThatFits)
//        .padding()
//        .background(.black)
//        .colorScheme(.dark)
    }
}
