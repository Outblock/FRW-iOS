//
//  WalletResetConfirmViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 25/10/2022.
//

import SwiftUI

class WalletResetConfirmViewModel: ObservableObject {
    // MARK: Internal

    @Published
    var text: String = ""

    func resetWalletAction() {
        if text != "delete_wallet_desc_2".localized {
            HUD.error(title: "reset_warning_text".localized)
            return
        }

        HUD.showAlert(
            title: "reset_warning_alert_title".localized,
            msg: "delete_warning_alert_desc".localized,
            cancelAction: {},
            confirmTitle: "delete_wallet".localized
        ) {
            self.doReset()
        }
    }

    // MARK: Private

    private func doReset() {
        HUD.loading()

        Task {
            do {
                try await UserManager.shared.reset()
                HUD.dismissLoading()
            } catch {
                log.error("reset failed", context: error)
                HUD.dismissLoading()
            }
        }
    }
}
