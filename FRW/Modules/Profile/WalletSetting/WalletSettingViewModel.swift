//
//  WalletSettingViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 24/10/2022.
//

import Flow
import SwiftUI

class WalletSettingViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        fetchAccountInfo()
    }

    // MARK: Internal

    @Published
    var storageUsedRatio: Double = 0
    @Published
    var storageUsedDesc: String = ""

    func resetWalletAction() {
        Router.route(to: RouteMap.Profile.resetWalletConfirm)
    }

    // MARK: Private

    private func fetchAccountInfo() {
        Task {
            do {
                let info = try await FlowNetwork.checkAccountInfo()
                DispatchQueue.main.async {
                    self.storageUsedRatio = info.storageUsedRatio
                    self.storageUsedDesc = info.storageUsedString
                }
            } catch {}
        }
    }
}
