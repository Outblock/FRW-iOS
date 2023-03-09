//
//  EnterPasswordViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 10/1/22.
//

import SwiftUI


class EnterRestorePasswordViewModel: ObservableObject {
    private let item: BackupManager.DriveItem
    
    init(driveItem: BackupManager.DriveItem) {
        self.item = driveItem
    }
    
    func restoreAction(password: String) {
        let mnemonicHexString = item.data.trim()
        
        do {
            let mnemoincString = try BackupManager.shared.decryptMnemonic(mnemonicHexString, password: password)
            restoreLogin(mnemonic: mnemoincString)
        } catch {
            HUD.error(title: "decrypt_failed".localized)
        }
    }
    
    private func restoreLogin(mnemonic: String) {
        HUD.loading()
        
        Task {
            do {
                try await UserManager.shared.restoreLogin(withMnemonic: mnemonic)
                
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
