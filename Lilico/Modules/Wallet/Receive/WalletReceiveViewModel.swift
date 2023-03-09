//
//  WalletReceiveViewModel.swift
//  Lilico
//
//  Created by Selina on 6/7/2022.
//

import SwiftUI

class WalletReceiveViewModel: ObservableObject {
    @Published var address: String
    
    init() {
        address = WalletManager.shared.getPrimaryWalletAddress() ?? "0x"
    }
    
    func copyAddressAction() {
        UIPasteboard.general.string = address
        HUD.success(title: "copied".localized)
    }
}
