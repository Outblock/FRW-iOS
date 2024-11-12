//
//  PrivateKeyView.swift
//  Flow Wallet
//
//  Created by Hao Fu on 7/9/2022.
//

import SwiftUI

// MARK: - PrivateKeyView

struct PrivateKeyView: RouteableView {
    @State
    var isBlur: Bool = true

    var title: String {
        "Private Key".localized.capitalized
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Section {
                    ZStack(alignment: .center) {
                        Text(WalletManager.shared.getCurrentPrivateKey() ?? "")
                            .foregroundColor(.LL.Neutrals.neutrals1)
                            .padding(25)
                            .background(.LL.bgForIcon)
                            .cornerRadius(16)
                            .blur(radius: isBlur ? 5 : 0)

                        if isBlur {
                            Label("Click to reveal".localized, systemImage: "eyes")
                                .foregroundColor(.LL.Neutrals.neutrals3)
                        }
                    }
                    .onTapGesture {
                        isBlur.toggle()
                    }
                    .animation(.easeInOut, value: isBlur)

                } header: {
                    HStack {
                        Text("Private Key".localized)
                            .foregroundColor(.LL.Neutrals.neutrals3)
                            .fontWeight(.semibold)
                        Spacer()

                        Button {
                            UIPasteboard.general.string = WalletManager.shared
                                .getCurrentPrivateKey() ?? ""
                            HUD.success(title: "copied".localized)
                        } label: {
                            Label(LocalizedStringKey("Copy".localized), colorImage: "Copy")
                                .foregroundColor(.Theme.Accent.grey)
                        }
                    }
                }

                Section {
                    Text(WalletManager.shared.getCurrentPublicKey() ?? "")
                        .padding(16)
                        .background(.LL.bgForIcon)
                        .cornerRadius(16)
                        .foregroundColor(.LL.Neutrals.neutrals1)

                } header: {
                    HStack {
                        Text("account_key_key".localized)
                            .foregroundColor(.LL.Neutrals.neutrals3)
                            .fontWeight(.semibold)
                        Spacer()

                        Button {
                            UIPasteboard.general.string = WalletManager.shared
                                .getCurrentPublicKey() ?? ""
                            HUD.success(title: "copied".localized)

                        } label: {
                            Label(LocalizedStringKey("Copy".localized), colorImage: "Copy")
                                .foregroundColor(.Theme.Accent.grey)
                        }
                    }
                }

                HStack {
                    HStack {
                        Divider()
                        VStack(alignment: .leading) {
                            Text("Hash__Algorithm::message".localized)
                                .font(.LL.footnote)
                                .foregroundColor(.LL.Neutrals.neutrals4)
                            Text(WalletManager.shared.hashAlgo.algorithm)
                                .font(.LL.body)
                                .foregroundColor(.LL.Neutrals.neutrals1)
                        }
                    }

                    Spacer()

                    HStack {
                        Divider()
                        VStack(alignment: .leading) {
                            Text("Sign__Algorithm::message".localized)
                                .font(.LL.footnote)
                                .foregroundColor(.LL.Neutrals.neutrals4)
                            Text(WalletManager.shared.signatureAlgo.id)
                                .font(.LL.body)
                                .foregroundColor(.LL.Neutrals.neutrals1)
                        }
                    }
                }.padding(.vertical, 10)

                VStack(spacing: 10) {
                    Text("not_share_secret_tips".localized)
                        .font(.LL.caption)
                        .bold()
                    Text("not_share_secret_desc".localized)
                        .font(.LL.footnote)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                .foregroundColor(.LL.warning2)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.LL.warning6)
                }
                .padding(.top)
                .padding(.bottom)

            }.padding(.horizontal, 18)
        }
        .backgroundFill(.LL.background)
        .applyRouteable(self)
    }
}

// MARK: - PrivateKeyScreen_Previews

struct PrivateKeyScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PrivateKeyView()
        }
    }
}

extension Label where Title == Text, Icon == Image {
    init(_ title: LocalizedStringKey, colorImage: String) {
        self.init {
            Text(title)
        } icon: {
            Image(colorImage)
                .renderingMode(.template)
        }
    }
}
