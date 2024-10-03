//
//  WalletReceiveViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 6/7/2022.
//

import SwiftUI

class WalletReceiveViewModel: ObservableObject {
    @Published var address: String

    init() {
        address = WalletManager.shared.selectedAccountAddress
    }

    func copyAddressAction() {
        UIPasteboard.general.string = address
        HUD.success(title: "copied".localized)
    }
}
