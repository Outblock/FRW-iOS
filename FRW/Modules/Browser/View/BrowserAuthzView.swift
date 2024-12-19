//
//  BrowserAuthzView.swift
//  Flow Wallet
//
//  Created by Selina on 6/9/2022.
//

import Highlightr
import Kingfisher
import SwiftUI

// MARK: - BrowserAuthzView

struct BrowserAuthzView: View, PresentActionDelegate {
    var changeHeight: (() -> Void)?
    
    // MARK: Lifecycle

    init(vm: BrowserAuthzViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    // MARK: Internal

    enum Selection: String, CaseIterable, Identifiable {
        case cadence
        case arguments

        // MARK: Internal

        var id: Self { self }
    }

    @StateObject
    var vm: BrowserAuthzViewModel

    @State
    var selection: Selection = .cadence

    var body: some View {
        ZStack {
            normalView.visibility(vm.isScriptShowing ? .invisible : .visible)
            scriptView.visibility(vm.isScriptShowing ? .visible : .invisible)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundFill(Color(hex: "#282828", alpha: 1))
    }

    var normalView: some View {
        VStack(spacing: 10) {
            titleView

//            Divider()
//                .foregroundColor(.LL.Neutrals.neutrals8)

            if let template = vm.template {
                verifiedView
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))

                VStack {
                    if let title = template.data.messages?.title?.i18N?.enUS {
                        Text(title)
                            .font(.LL.body)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let description = template.data.messages?.messagesDescription?.i18N?.enUS {
                        Text(description)
                            .font(.LL.footnote)
                            .foregroundColor(.LL.Neutrals.note)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 18)
                .background(Color(hex: "#313131"))
                .cornerRadius(12)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
            } else {
                feeView
                    .padding(.top, 12)
            }
            scriptButton
                .padding(.top, 8)

            Spacer()

            actionView
        }
        .if(let: vm.template) {
            $0.animation(.spring(), value: $1)
        }
        .task {
            vm.checkTemplate()
            vm.formatCode()
            vm.formatArguments()
        }
        .padding(.all, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundFill(Color(hex: "#282828", alpha: 1))
    }

    var verifiedView: some View {
        HStack(alignment: .center) {
            Image(systemName: "checkmark.shield.fill")
                .font(.LL.body)
            Text("This transaction is verified")
                .font(.LL.body)
                .fontWeight(.semibold)
        }
        .foregroundColor(.LL.success)
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .backgroundFill(.LL.success.opacity(0.16))
        .cornerRadius(12)
    }

    var titleView: some View {
        HStack(spacing: 18) {
            KFImage.url(URL(string: vm.logo ?? ""))
                .placeholder {
                    Image("placeholder")
                        .resizable()
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 64, height: 64)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text("browser_transaction_request_from".localized)
                    .font(.inter(size: 14))
                    .foregroundColor(Color(hex: "#808080"))

                Text(vm.title)
                    .font(.inter(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var feeView: some View {
        HStack(spacing: 12) {
            Image("icon-fee")

            Text("browser_transaction_fee".localized)
                .font(.inter(size: 14, weight: .regular))
                .foregroundColor(Color(hex: "#F2F2F2"))
                .lineLimit(1)

            Spacer()

            Image("Flow")
                .resizable()
                .frame(width: 16, height: 16)

            Text(RemoteConfigManager.shared.freeGasEnabled ? "0" : "0.001")
                .font(.inter(size: 18, weight: .medium))
                .foregroundColor(Color(hex: "#FAFAFA"))
                .lineLimit(1)
        }
        .frame(height: 46)
        .padding(.horizontal, 18)
        .background(Color(hex: "#313131"))
        .cornerRadius(12)
    }

    var scriptButton: some View {
        Button {
            vm.changeScriptViewShowingAction(true)
        } label: {
            HStack(spacing: 12) {
                Image("icon-script")

                Text("browser_script".localized)
                    .font(.inter(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "#F2F2F2"))
                    .lineLimit(1)

                Spacer()

                Image("icon-search-arrow")
                    .resizable()
                    .frame(width: 12, height: 12)
            }
            .frame(height: 46)
            .padding(.horizontal, 18)
            .background(Color(hex: "#313131"))
            .cornerRadius(12)
        }
    }

    var actionView: some View {
        VStack(spacing: 0) {
            InsufficientStorageToastView<BrowserAuthzViewModel>()
                .environmentObject(self.vm)
            
            WalletSendButtonView(allowEnable: .constant(true)) {
                vm.didChooseAction(true)
            }
        }
    }

    var scriptView: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack(spacing: 0) {
                    Button {
                        vm.changeScriptViewShowingAction(false)
                    } label: {
                        Image("icon-back-arrow-grey")
                            .frame(height: 72)
                            .contentShape(Rectangle())
                    }

                    Spacer()
                }

                Text("browser_script_title".localized)
                    .font(.inter(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#E8E8E8"))
            }
            .frame(height: 72)

            Picker("Cadence", selection: $selection) {
                ForEach(BrowserAuthzView.Selection.allCases) { topping in
                    Text(topping.rawValue.capitalized)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 8)

            ScrollView(.vertical, showsIndicators: false) {
                Text(attributeString())
                    .font(.inter(
                        size: selection == .cadence ? 8 : 14,
                        weight: selection == .cadence ? .light : .regular
                    ))
                    .foregroundColor(Color(hex: "#B2B2B2"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(.all, 18)
                    .background(Color(hex: "#313131"))
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundFill(Color(hex: "#282828", alpha: 1))
        .transition(.move(edge: .trailing))
    }

    func attributeString() -> AttributedString {
        switch selection {
        case .cadence:
            vm.cadenceFormatted ?? AttributedString(vm.cadence.trim())
        case .arguments:
            vm.argumentsFormatted ?? AttributedString(vm.arguments?.jsonPrettyPrint()?.trim() ?? "")
        }
    }
}

// MARK: - BrowserAuthzView_Previews

struct BrowserAuthzView_Previews: PreviewProvider {
    static let vm = BrowserAuthzViewModel(
        title: "This is title",
        url: "This is URL",
        logo: "https://lilico.app/logo.png",
        cadence: """
        import FungibleToken from 0x9a0766d93b6608b7
        transaction(amount: UFix64, to: Address) {
        let vault: @FungibleToken.Vault
        prepare(signer: AuthAccount) {
        self.vault <- signer
        .borrow<&{FungibleToken.Provider}>(from: /storage/flowTokenVault)!
        .withdraw(amount: amount)
        }
        execute {
        getAccount(to)
        .getCapability(/public/flowTokenReceiver)!
        .borrow<&{FungibleToken.Receiver}>()!
        .deposit(from: <-self.vault)
        }
        }
        """
    ) { _ in }

    static var previews: some View {
        BrowserAuthzView(vm: vm)
    }
}
