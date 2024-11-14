//
//  RestoreMultiAccountViewModel.swift
//  FRW
//
//  Created by cat on 2024/1/7.
//

import FlowWalletCore
import Foundation

class RestoreMultiAccountViewModel: ObservableObject {
    // MARK: Lifecycle

    init(items: [[MultiBackupManager.StoreItem]]) {
        self.items = items
    }

    // MARK: Internal

    var items: [[MultiBackupManager.StoreItem]]

    func onClickUser(at index: Int) {
        guard index < items.count else {
            return
        }
        let selectedUser = items[index]

        guard let selectedUserId = selectedUser.first?.userId else {
            log.error("[restore] invaid user id")
            return
        }

        // If it is the current user, do nothing and return directly.
        if let userId = UserManager.shared.activatedUID, userId == selectedUserId {
            if (try? WallectSecureEnclave.Store.fetchModel(by: selectedUserId)) != nil {
                Router.popToRoot()
                return
            }
            if let mnemonic = WalletManager.shared.getMnemonicFromKeychain(uid: selectedUserId),
               !mnemonic.isEmpty {
                Router.popToRoot()
                return
            }
        }

        // If it is in the login list, switch user
        if UserManager.shared.loginUIDList.contains(selectedUserId) {
            var isValidKey = false
            if (try? WallectSecureEnclave.Store.fetchModel(by: selectedUserId)) != nil {
                isValidKey = true
            }
            if let mnemonic = WalletManager.shared.getMnemonicFromKeychain(uid: selectedUserId),
               !mnemonic.isEmpty {
                isValidKey = true
            }

            if isValidKey {
                Task {
                    do {
                        HUD.loading()
                        try await UserManager.shared.switchAccount(withUID: selectedUserId)
                        MultiAccountStorage.shared.setBackupType(.multi, uid: selectedUserId)
                        HUD.dismissLoading()
                    } catch {
                        log.error("switch account failed", context: error)
                        HUD.dismissLoading()
                        HUD.error(title: error.localizedDescription)
                    }
                }
                return
            }
        }

        guard selectedUser.count > 1 else {
            return
        }
        Task {
            do {
                HUD.loading()
                try await MultiBackupManager.shared.addKeyToAccount(with: selectedUser)
                HUD.dismissLoading()
            } catch {
                log.error("add new device failed", context: error)
                HUD.dismissLoading()
                // TODO: des
                HUD.error(title: "restore failed")
            }
        }
    }
}
