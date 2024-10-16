//
//  RecoveryPhraseViewModel.swift
//  Flow Wallet
//
//  Created by Hao Fu on 3/1/22.
//

import SPIndicator
import UIKit

class RecoveryPhraseViewModel: ViewModel {
    @Published private(set) var state: RecoveryPhraseView.ViewState

    let mockData = [
        WordListView.WordItem(id: 1, word: "---"),
        WordListView.WordItem(id: 2, word: "---"),
        WordListView.WordItem(id: 3, word: "---"),
        WordListView.WordItem(id: 4, word: "---"),
        WordListView.WordItem(id: 5, word: "---"),
        WordListView.WordItem(id: 6, word: "---"),
        WordListView.WordItem(id: 7, word: "---"),
        WordListView.WordItem(id: 8, word: "---"),
        WordListView.WordItem(id: 9, word: "---"),
        WordListView.WordItem(id: 10, word: "---"),
        WordListView.WordItem(id: 11, word: "---"),
        WordListView.WordItem(id: 12, word: "---"),
    ]

    init() {
        if let mnemonic = WalletManager.shared.getCurrentMnemonic() {
            state = RecoveryPhraseView.ViewState(dataSource: mnemonic.split(separator: " ").enumerated().map { item in
                WordListView.WordItem(id: item.offset + 1, word: String(item.element))
            })
        } else {
            state = RecoveryPhraseView.ViewState(dataSource: mockData)
        }
    }

    func trigger(_ input: RecoveryPhraseView.Action) {
        switch input {
        case .icloudBackup:
            Router.route(to: RouteMap.Backup.backupToCloud(.icloud))
        case .googleBackup:
            Router.route(to: RouteMap.Backup.backupToCloud(.googleDrive))
        case .manualBackup:
            Router.route(to: RouteMap.Backup.backupManual)
        case .copy:
            UIPasteboard.general.string = WalletManager.shared.getCurrentMnemonic() ?? ""
            HUD.success(title: "copied".localized)
        }
    }
}
