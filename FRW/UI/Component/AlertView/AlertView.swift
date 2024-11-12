//
//  AlertView.swift
//  Flow Wallet
//
//  Created by Selina on 29/7/2022.
//

import SwiftUI

extension AlertView {
    enum ButtonsLayout {
        case horizontal, vertical
    }
    
    enum ButtonType {
        case normal
        case confirm
        case primaryAction
        case secondaryAction

        var titleColor: Color {
            switch self {
            case .normal:
                return Color.LL.Button.color
            case .confirm:
                return Color.LL.Button.text
            case .primaryAction:
                return Color.LL.Button.Primary.text
            case .secondaryAction:
                return Color.LL.Button.Elevated.text
            }
        }

        var bgColor: Color {
            switch self {
            case .normal:
                return Color.LL.Button.text
            case .confirm:
                return Color.LL.Neutrals.neutrals1
            case .primaryAction:
                return Color.Theme.Accent.green
            case .secondaryAction:
                return Color.LL.Button.Elevated.Secondary.background
            }
        }

        var font: Font {
            return .inter(size: 14, weight: .semibold)
        }
    }

    struct ButtonItem {
        let id: String = UUID().uuidString
        let type: AlertView.ButtonType
        let title: String
        let action: () -> Void
    }
}

struct AlertView: ViewModifier {
    @Binding var isPresented: Bool
    let title: String?
    let desc: String?
    let attributedDesc: NSAttributedString?
    let customContentView: AnyView?
    let buttons: [AlertView.ButtonItem]
    let useDefaultCancelButton: Bool
    let showCloseButton: Bool
    let buttonsLayout: ButtonsLayout
    let textAlignment: TextAlignment
    private var _textAlignment: Alignment {
        switch self.textAlignment {
        case .center: return .center
        case .leading: return .leading
        case .trailing: return .trailing
        }
    }

    let testString: AttributedString = {
        let normalDict = [NSAttributedString.Key.foregroundColor: UIColor.LL.Neutrals.text]
        let highlightDict = [NSAttributedString.Key.foregroundColor: UIColor.LL.Primary.salmonPrimary]

        var str = NSMutableAttributedString(string: "this is a ", attributes: normalDict)
        str.append(NSMutableAttributedString(string: "highlight", attributes: highlightDict))
        str.append(NSMutableAttributedString(string: " string", attributes: normalDict))

        return AttributedString(str)
    }()

    func body(content: Content) -> some View {
        ZStack {
            content

            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .transition(.opacity)
                .visibility(isPresented ? .visible : .gone)

            contentView
                .padding(.bottom, 45)
                .visibility(isPresented ? .visible : .gone)
        }
        .multilineTextAlignment(self.textAlignment)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension AlertView {
    var contentView: some View {
        VStack(spacing: 27) {
            VStack(alignment: .leading, spacing: 10) {
                Text(title ?? "")
                    .foregroundColor(Color.LL.Neutrals.text)
                    .font(.inter(size: 20, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: self._textAlignment)
                    .padding(.horizontal, 8)
                    .visibility(title != nil ? .visible : .gone)

                VStack(spacing: 0) {
                    if let customContentView {
                        customContentView
                    } else {
                        if let desc {
                            // The explicit `.init` call enables markdown. SwiftUI bug.
                            Text(.init(desc))
                        } else if let attributedDesc {
                            Text(AttributedString(attributedDesc))
                        }
                    }
                }
                .foregroundColor(Color.LL.Neutrals.text)
                .font(.inter(size: 14, weight: .regular))
                .frame(maxWidth: .infinity, alignment: self._textAlignment)
                .visibility((desc != nil || attributedDesc != nil || customContentView != nil) ? .visible : .gone)
            }

            switch self.buttonsLayout {
            case .vertical:
                VStack(spacing: 8) {
                    self.buttonsList
                }
            case .horizontal:
                HStack(spacing: 16) {
                    self.buttonsList
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 25)
        .padding(.bottom, 15)
        .background(Color.LL.Neutrals.background)
        .cornerRadius(16)
        .padding(.horizontal, 28)
        .zIndex(.infinity)
        .transition(.scale)
        .overlay(alignment: .topTrailing) {
            Button {
                self.isPresented = false
            } label: {
                Image("icon_close_circle_gray")
                    .foregroundColor(.gray)
                    .frame(width: 16, height: 16)
                    .padding(12)
            }
            .visibility(self.showCloseButton ? .visible : .gone)
            .padding(.trailing, 36)
            .padding(.top, 18)
        }
    }

    @ViewBuilder
    private var buttonsList: some View {
        ForEach(buttons, id: \.id) { btn in
            Button {
                closeAction()
                btn.action()
            } label: {
                createButtonLabel(item: btn)
            }
        }
        
        defaultCancelButton
            .visibility(useDefaultCancelButton ? .visible : .gone)
    }
    
    var defaultCancelButton: some View {
        let btn = AlertView.ButtonItem(type: .normal, title: "cancel".localized, action: {})
        return Button {
            closeAction()
        } label: {
            createButtonLabel(item: btn)
        }
    }

    @ViewBuilder func createButtonLabel(item: AlertView.ButtonItem) -> some View {
        Text(item.title)
            .font(item.type.font)
            .foregroundColor(item.type.titleColor)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background {
                item.type.bgColor.cornerRadius(12)
            }
    }
}

extension AlertView {
    private func closeAction() {
        withAnimation(.alertViewSpring) {
            isPresented = false
        }
    }
}

extension View {
    func customAlertView(
        isPresented: Binding<Bool>,
        title: String? = nil,
        desc: String? = nil,
        attributedDesc: NSAttributedString? = nil,
        customContentView: AnyView? = nil,
        buttons: [AlertView.ButtonItem] = [],
        useDefaultCancelButton: Bool = true,
        showCloseButton: Bool = false,
        buttonsLayout: AlertView.ButtonsLayout = .vertical,
        textAlignment: TextAlignment = .leading
    ) -> some View {
        modifier(AlertView(isPresented: isPresented, title: title, desc: desc, attributedDesc: attributedDesc, customContentView: customContentView, buttons: buttons, useDefaultCancelButton: useDefaultCancelButton, showCloseButton: showCloseButton, buttonsLayout: buttonsLayout, textAlignment: textAlignment))
    }
}

struct AlertViewTestView: View {
    @State var isPresented: Bool = true
    let desc = "No account found with the recoveray phrase. Do you want to create a new account with your phrase?"

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isPresented = true
            }
        } label: {
            Text("test")
        }
        .customAlertView(isPresented: $isPresented, title: "Account not Found", desc: desc, buttons: [confirmBtn])
    }

    var confirmBtn: AlertView.ButtonItem {
        let confirmBtn = AlertView.ButtonItem(type: .confirm, title: "Create Wallet") {}

        return confirmBtn
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertViewTestView()
    }
}

#Preview("Insufficient Storage") {
    let customContentView: () -> some View = {
        VStack(alignment: .center, spacing: 8) {
            Text(.init("insufficient_storage::error::content::first".localized))
            Text(.init("insufficient_storage::error::content::second".localized(0.021)))
                .foregroundColor(Color.LL.Button.Warning.background)
            Text(.init("insufficient_storage::error::content::third".localized))
                .padding(.top, 8)
        }
        .padding(.vertical, 8)
    }
    
    EmptyView()
        .customAlertView(
            isPresented: .constant(true),
            title: .init("insufficient_storage::error::title".localized),
            customContentView: AnyView(customContentView()),
            buttons: [
                AlertView.ButtonItem(type: .secondaryAction, title: "Deposit", action: {}),
                AlertView.ButtonItem(type: .primaryAction, title: "Buy FLOW", action: {})
            ],
            useDefaultCancelButton: false,
            buttonsLayout: .horizontal,
            textAlignment: .center
        )
}
