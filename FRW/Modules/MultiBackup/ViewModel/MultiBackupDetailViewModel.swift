//
//  MultiBackupDetailViewModel.swift
//  FRW
//
//  Created by cat on 2024/1/9.
//

import Flow
import SwiftUI

class MultiBackupDetailViewModel: ObservableObject {
    // MARK: Lifecycle

    init(item: KeyDeviceModel) {
        self.item = item
        if let backupType = item.multiBackupType() {
            if backupType == .google || backupType == .icloud {
                showPhrase = true
            }
        }
    }

    // MARK: Internal

    var item: KeyDeviceModel

    @Published
    var showRemoveTipView = false
    @Published
    var showPhrase = false

    func onDelete() {
        if showRemoveTipView {
            showRemoveTipView = false
        }
        withAnimation(.easeOut(duration: 0.2)) {
            showRemoveTipView = true
        }
    }

    func onCancelTip() {
        showRemoveTipView = false
    }

    func deleteMultiBackup() {
        guard let keyIndex = item.backupInfo?.keyIndex,
              let type = item.multiBackupType() else { return }

        Task {
            HUD.loading()

            let res = try await AccountKeyManager.revokeKey(at: keyIndex)
            if res {
                try await MultiBackupManager.shared.removeItem(with: type)
                DispatchQueue.main.async {
                    self.showRemoveTipView = false
                }
                Router.pop()
            }
            HUD.dismissLoading()
        }
    }

    func onDisplayPharse() {
        guard let backupType = item.multiBackupType(),
              backupType == .google || backupType == .icloud
        else {
            return
        }

        Task {
            let list = try await MultiBackupManager.shared.getCloudDriveItems(from: backupType)
            Router.route(to: RouteMap.Backup.verityPin(.restore) { allow, pin in
                if allow {
                    let verifyList = self.verify(list: list, with: pin)
                    let validItem = verifyList.filter { $0.publicKey == self.item.pubkey.publicKey }
                        .first
                    if let result = validItem {
                        do {
                            let mnemonic = try MultiBackupManager.shared.decryptMnemonic(
                                result.data,
                                password: pin.toPassword() ?? ""
                            )
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                Router.route(to: RouteMap.Backup.showPhrase(mnemonic))
                            }
                        } catch {
                            HUD.error(title: "invalid mnemonic")
                            log.error("invalid mnemonic")
                        }
                    } else {
                        HUD.error(title: "no match mnemonic")
                        log.error("no match mnemonic")
                    }
                }
            })
        }
    }

    // MARK: Private

    private func verify(
        list: [MultiBackupManager.StoreItem],
        with pin: String
    ) -> [MultiBackupManager.StoreItem] {
        let pinCode = pin.toPassword() ?? pin
        var result: [MultiBackupManager.StoreItem] = []

        for item in list {
            do {
                _ = try MultiBackupManager.shared.decryptMnemonic(item.data, password: pinCode)
                var newItem = item

                newItem.code = pin
                result.append(newItem)
            } catch {
                log.error(error)
            }
        }
        return result
    }
}
