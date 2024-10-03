//
//  CreateRecoveryPhraseBackupViewModel.swift
//  FRW
//
//  Created by cat on 2024/9/19.
//

import Flow
import Foundation
import KeychainAccess
import UIKit
import WalletCore

class CreateRecoveryPhraseBackupViewModel: ObservableObject {
    var mnemonic: String

    var dataSource: [WordListView.WordItem] = []

    init(mnemonic: String) {
        self.mnemonic = mnemonic
        dataSource = mnemonic.split(separator: " ").enumerated().map { item in
            WordListView.WordItem(id: item.offset + 1, word: String(item.element))
        }
    }

    func onCreate() {
        Router.route(to: RouteMap.Backup.backupCompleted(mnemonic))
    }

    func onCopy() {
        guard !mnemonic.isEmpty else {
            return
        }
        UIPasteboard.general.string = mnemonic
        HUD.success(title: "copied".localized)
    }
}
