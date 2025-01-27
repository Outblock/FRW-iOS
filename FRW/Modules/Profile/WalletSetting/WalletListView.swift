//
//  WalletListView.swift
//  FRW
//
//  Created by cat on 2024/5/28.
//

import SwiftUI

// MARK: - WalletListViewModel

class WalletListViewModel: ObservableObject {
    @Published
    var mainWallets: [AccountCell.Item] = []
    @Published
    var multiVMWallets: [AccountCell.Item] = []

    func reload() {
        mainWallets = []
        if let mainAddress = WalletManager.shared.getPrimaryWalletAddress() {
            let user = WalletManager.shared.walletAccount.readInfo(at: mainAddress)
            var balance = WalletManager.shared.balanceProvider.balanceValue(at: mainAddress) ?? ""
            if !balance.isEmpty {
                balance += " Flow"
            }
            let mainWallet = AccountCell.Item(
                user: user,
                address: mainAddress,
                balance: balance,
                isEvm: false
            )
            mainWallets.append(mainWallet)
        }
        multiVMWallets = []
        for account in EVMAccountManager.shared.accounts {
            let user = WalletManager.shared.walletAccount.readInfo(at: account.showAddress)
            var balance = WalletManager.shared.balanceProvider
                .balanceValue(at: account.showAddress) ?? ""
            if !balance.isEmpty {
                balance += " Flow"
            }
            let model = AccountCell.Item(
                user: user,
                address: account.showAddress,
                balance: balance,
                isEvm: true
            )
            multiVMWallets.append(model)
        }
    }

    func addAccount() {
        Router.route(to: RouteMap.Register.root(nil))
    }
}

// MARK: - WalletListView

struct WalletListView: RouteableView {
    @StateObject
    var viewModel = WalletListViewModel()

    var title: String {
        "wallet_list".localized
    }

    var body: some View {
        VStack {
            ScrollView {
                Section {
                    ForEach(viewModel.mainWallets, id: \.address) { item in
                        Button {
                            Router.route(to: RouteMap.Profile.walletSetting(true, item.address))
                        } label: {
                            AccountCell(item: item)
                        }
                    }
                } header: {
                    HStack {
                        Text("main_accounts".localized)
                            .font(.inter(size: 14, weight: .semibold))
                            .foregroundStyle(Color.Theme.Text.black3)
                        Spacer()
                    }
                }

                Section {
                    ForEach(viewModel.multiVMWallets, id: \.address) { item in
                        Button {
                            Router.route(to: RouteMap.Profile.walletSetting(true, item.address))
                        } label: {
                            AccountCell(item: item)
                        }
                    }
                } header: {
                    HStack {
                        Text("evm_accounts".localized)
                            .font(.inter(size: 14, weight: .semibold))
                            .foregroundStyle(Color.Theme.Text.black3)
                        Spacer()
                    }
                }
                .visibility(!viewModel.multiVMWallets.isEmpty ? .visible : .gone)
            }
        }
        .padding(.horizontal, 18)
        .backgroundFill(.LL.background)
        .applyRouteable(self)
//        .navigationBarItems(trailing: HStack(spacing: 6) {
//            Button {
//                viewModel.addAccount()
//            } label: {
//                Image("btn-add")
//                    .renderingMode(.template)
//                    .foregroundColor(.Theme.Text.black8)
//            }
//        })
        .onAppear(perform: {
            viewModel.reload()
        })
    }
}

#Preview {
    WalletListView()
}
