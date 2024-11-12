//
//  ReceiveQRViewModel.swift
//  FRW
//
//  Created by cat on 2024/2/26.
//

import SwiftUI

class ReceiveQRViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        self.address = flowAddr()
        self.name = flowName()
    }

    // MARK: Internal

    @Published
    var name: String = ""
    @Published
    var address: String = ""

    @Published
    var isEVM: Bool = false

    var hasEVM: Bool {
        EVMAccountManager.shared.hasAccount
    }

    func onClickCopy() {
        UIPasteboard.general.string = address
        HUD.success(title: "copied".localized)
    }

    func onChangeChain(isEvm: Bool) {
        isEVM = isEvm
        address = isEvm ? EVMAddr() : flowAddr()
        name = isEvm ? EVMName() : flowName()
    }

    // MARK: Private

    private func flowName() -> String {
        var name = UserManager.shared.userInfo?.nickname ?? "lilico".localized
        if let account = ChildAccountManager.shared.selectedChildAccount {
            name = account.showName
        }
        return name
    }

    private func flowAddr() -> String {
        var address = WalletManager.shared.getPrimaryWalletAddress() ?? ""
        if let account = ChildAccountManager.shared.selectedChildAccount {
            address = account.showAddress
        }
        return address
    }

    private func EVMName() -> String {
        UserManager.shared.userInfo?.nickname ?? "lilico".localized
    }

    private func EVMAddr() -> String {
        EVMAccountManager.shared.accounts.first?.showAddress ?? ""
    }
}
