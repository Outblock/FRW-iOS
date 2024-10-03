//
//  SecureEnclavePrivateKeyView.swift
//  FRW
//
//  Created by cat on 2024/9/16.
//

import SwiftUI

struct SecureEnclavePrivateKeyView: RouteableView {
    var title: String {
        "Private Key".localized.capitalized
    }

    var learnMoreUrl: String {
        return "https://frw.gitbook.io/doc/faq/faq#where-is-my-seed-phrase-i-cant-find-it-on-flow-wallet-ios-or-android"
    }

    var publicKey: String {
        WalletManager.shared.getCurrentPublicKey() ?? ""
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Section {
                    HStack {
                        Text(publicKey)
                            .font(.inter(size: 12))
                            .foregroundColor(.Theme.Text.black8)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(.Theme.Background.grey)
                    .cornerRadius(16)
                    .padding(.bottom, 24)

                } header: {
                    HStack {
                        Text("account_key_key".localized)
                            .font(.inter(size: 14, weight: .bold))
                            .foregroundColor(.Theme.Text.black3)

                        Spacer()

                        Button {
                            UIPasteboard.general.string = publicKey
                            HUD.success(title: "copied".localized)
                        } label: {
                            Label(LocalizedStringKey("Copy".localized), colorImage: "Copy")
                                .foregroundColor(.Theme.Accent.grey)
                        }
                    }
                    .padding(.bottom, 12)
                }
                .visibility(publicKey.isEmpty ? .gone : .visible)

                Section {
                    VStack(spacing: 24) {
                        Text("private_key_secured_hint".localized)
                            .font(.inter(size: 12))
                            .foregroundColor(.Theme.Text.black8)

                        Button {
                            if let url = URL(string: learnMoreUrl) {
                                UIApplication.shared.open(url)
                            }

                        } label: {
                            Text("Learn__more::message".localized)
                                .font(.inter(size: 14, weight: .semibold))
                                .foregroundStyle(Color.Theme.Accent.blue)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(.Theme.Accent.blue.opacity(0.12))
                    .cornerRadius(16)
                    .padding(.bottom, 24)

                } header: {
                    HStack(spacing: 4) {
                        Text("Private Key".localized)
                            .font(.inter(size: 14, weight: .bold))
                            .foregroundColor(.Theme.Text.black3)

                        Spacer()

                        Image(systemName: "shield.fill")
                            .foregroundStyle(Color.Theme.Accent.green)
                            .font(.system(size: 14))
                        Text("secured_by_se".localized)
                            .foregroundStyle(Color.Theme.Accent.green)
                            .font(.inter(size: 12, weight: .bold))
                    }
                    .padding(.bottom, 12)
                }

                HStack {
                    HStack(spacing: 16) {
                        Divider()
                        VStack(alignment: .leading) {
                            Text("Hash Algotithm")
                                .font(.inter(size: 12))
                                .foregroundColor(Color.Theme.Text.black3)

                            Text(WalletManager.shared.hashAlgo.algorithm)
                                .font(.inter(size: 12))
                                .foregroundColor(Color.Theme.Text.black3)
                        }
                    }

                    Spacer()

                    HStack(spacing: 16) {
                        Divider()
                        VStack(alignment: .leading) {
                            Text("Sign Algotithm")
                                .font(.inter(size: 12))
                                .foregroundColor(Color.Theme.Text.black3)

                            Text(WalletManager.shared.signatureAlgo.id)
                                .font(.inter(size: 12))
                                .foregroundColor(Color.Theme.Text.black3)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            .padding(.horizontal, 18)
        }
        .backgroundFill(.LL.background)
        .applyRouteable(self)
    }
}

#Preview {
    SecureEnclavePrivateKeyView()
}
