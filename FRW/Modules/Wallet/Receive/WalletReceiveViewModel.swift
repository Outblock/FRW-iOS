//
//  WalletReceiveViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 6/7/2022.
//

import SwiftUI

class WalletReceiveViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        self.address = WalletManager.shared.selectedAccountAddress
    }

    // MARK: Internal

    @Published
    var address: String

    func copyAddressAction() {
        UIPasteboard.general.string = address
        HUD.success(title: "copied".localized)
    }
}
