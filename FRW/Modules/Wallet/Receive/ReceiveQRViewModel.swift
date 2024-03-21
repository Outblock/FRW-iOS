//
//  ReceiveQRViewModel.swift
//  FRW
//
//  Created by cat on 2024/2/26.
//

import SwiftUI

class ReceiveQRViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var address: String = ""
    
    @Published var isEVM: Bool = false
    
    init() {
        address = flowAddr()
        name = flowName()
    }
    
    var hasEVM: Bool {
        return EVMAccountManager.shared.hasAccount
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
    
    private func flowName() -> String {
        UserManager.shared.userInfo?.nickname ?? "lilico".localized
    }
    
    private func flowAddr() -> String {
        WalletManager.shared.selectedAccountAddress
    }
    
    private func EVMName() -> String {
        UserManager.shared.userInfo?.nickname ?? "lilico".localized
    }
    
    private func EVMAddr() -> String {
        WalletManager.shared.selectedAccountAddress + WalletManager.shared.selectedAccountAddress
    }
}
