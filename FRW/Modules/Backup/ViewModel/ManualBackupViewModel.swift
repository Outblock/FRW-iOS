//
//  ManualBackupViewModel.swift
//  Flow Reference Wallet
//
//  Created by Hao Fu on 4/1/22.
//

import Foundation
import SPConfetti
import WalletCore
import SwiftUI

class ManualBackupViewModel: ViewModel {
    @Published
    private(set) var state: ManualBackupView.ViewState = .initScreen

    func loadScreen() {
        
        SPConfettiConfiguration.particlesConfig.colors = [ Color.LL.Primary.salmonPrimary.toUIColor()!,
                                                           Color.LL.Secondary.mangoNFT.toUIColor()!,
                                                           Color.LL.Secondary.navy4.toUIColor()!,
                                                           Color.LL.Secondary.violetDiscover.toUIColor()!]
        SPConfettiConfiguration.particlesConfig.velocity = 400
        SPConfettiConfiguration.particlesConfig.velocityRange = 200
        SPConfettiConfiguration.particlesConfig.birthRate = 200
        SPConfettiConfiguration.particlesConfig.spin = 4

        guard var mnemonic = WalletManager.shared.getCurrentMnemonic(), !mnemonic.isEmpty else {
            HUD.error(title: "load_wallet_error".localized)
            return
        }
        
        defer {
            mnemonic = ""
        }

        let wordList = mnemonic.split(separator: " ")

        guard wordList.count == 12 else {
            HUD.error(title: "inocrrect_world_length".localized)
            return
        }

        let positions = [Int.random(in: 0 ... 2),
                         Int.random(in: 3 ... 5),
                         Int.random(in: 6 ... 8),
                         Int.random(in: 9 ... 11)]

        var dataSource: [ManualBackupView.BackupModel] = []
        for position in positions {
            let word = String(wordList[position])
            let matches = Mnemonic.search(prefix: String(word.prefix(1)))
            var matchList = matches.filter { $0 != word }.shuffled()[0 ... 1]
            matchList.append(word)
            matchList.shuffle()
            let firstIndex = matchList.firstIndex(of: word)
            dataSource.append(.init(position: position + 1,
                                    correct: firstIndex ?? 0,
                                    list: Array(matchList))
            )
        }

        DispatchQueue.main.async {
            self.state = .render(dataSource: dataSource)
        }
    }

    func trigger(_ input: ManualBackupView.Action) {
        switch input {
        case .backupSuccess:
            guard let uid = UserManager.shared.activatedUID else { return }
            MultiAccountStorage.shared.setBackupType(.manual, uid: uid)
            
            Router.popToRoot()
            SPConfetti.startAnimating(.fullWidthToDown,
                                      particles: [.triangle, .arc, .polygon, .heart, .star],
                                      duration: 4)
        case .loadDataSource:
            loadScreen()
        }
    }
}
