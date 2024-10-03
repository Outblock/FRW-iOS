//
//  AlertView.swift
//  Flow Wallet
//
//  Created by Selina on 29/7/2022.
//

import SwiftUI

extension AlertView {
    enum ButtonType {
        case normal
        case confirm

        var titleColor: Color {
            switch self {
            case .normal:
                return Color.LL.Button.color
            case .confirm:
                return Color.LL.Button.text
            }
        }

        var bgColor: Color {
            switch self {
            case .normal:
                return Color.LL.Button.text
            case .confirm:
                return Color.LL.Neutrals.neutrals1
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
    let buttons: [AlertView.ButtonItem]
    let useDefaultCancelButton: Bool

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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .visibility(title != nil ? .visible : .gone)

                Text(AttributedString(attributedDesc ?? NSAttributedString(string: desc ?? "")))
                    .foregroundColor(Color.LL.Neutrals.text)
                    .font(.inter(size: 14, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .visibility((desc != nil || attributedDesc != nil) ? .visible : .gone)
            }

            VStack(spacing: 8) {
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
        }
        .padding(.horizontal, 24)
        .padding(.top, 25)
        .padding(.bottom, 15)
        .background(Color.LL.Neutrals.background)
        .cornerRadius(16)
        .padding(.horizontal, 28)
        .zIndex(.infinity)
        .transition(.scale)
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
    func customAlertView(isPresented: Binding<Bool>,
                         title: String? = nil,
                         desc: String? = nil,
                         attributedDesc: NSAttributedString? = nil,
                         buttons: [AlertView.ButtonItem] = [],
                         useDefaultCancelButton: Bool = true) -> some View
    {
        modifier(AlertView(isPresented: isPresented, title: title, desc: desc, attributedDesc: attributedDesc, buttons: buttons, useDefaultCancelButton: useDefaultCancelButton))
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
