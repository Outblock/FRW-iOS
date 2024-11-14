//
//  EnterRestorePasswordViewModel.swift
//  Flow Wallet
//
//  Created by Hao Fu on 10/1/22.
//

import SwiftUI

class EnterRestorePasswordViewModel: ObservableObject {
    // MARK: Lifecycle

    init(driveItem: BackupManager.DriveItem, backupType: BackupManager.BackupType) {
        self.item = driveItem
        self.backupType = backupType
    }

    // MARK: Internal

    func restoreAction(password: String) {
        let mnemonicHexString = item.data.trim()

        do {
            let mnemoincString = try BackupManager.shared.decryptMnemonic(
                mnemonicHexString,
                password: password
            )
            restoreLogin(mnemonic: mnemoincString)
        } catch {
            HUD.error(title: "decrypt_failed".localized)
        }
    }

    // MARK: Private

    private let item: BackupManager.DriveItem
    private let backupType: BackupManager.BackupType

    private func restoreLogin(mnemonic: String) {
        HUD.loading()

        Task {
            do {
                try await UserManager.shared.restoreLogin(withMnemonic: mnemonic)

                DispatchQueue.main.async {
                    if let uid = UserManager.shared.activatedUID,
                       MultiAccountStorage.shared.getBackupType(uid) == .none {
                        MultiAccountStorage.shared.setBackupType(self.backupType, uid: uid)
                    }
                }

                HUD.dismissLoading()
                HUD.success(title: "login_success".localized)

                Router.popToRoot()
            } catch {
                debugPrint("EnterRestorePasswordViewModel -> login failed: \(error)")
                HUD.dismissLoading()
                HUD.error(title: "login_failed".localized)
            }
        }
    }
}
