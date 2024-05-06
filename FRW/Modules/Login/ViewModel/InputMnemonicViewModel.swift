//
//  InputMnemonicViewModel.swift
//  Flow Wallet
//
//  Created by Hao Fu on 8/1/22.
//

import Foundation
import WalletCore
import SwiftUI

class InputMnemonicViewModel: ViewModel {
    @Published var state: InputMnemonicView.ViewState = .init()

    func trigger(_ input: InputMnemonicView.Action) {
        switch input {
        case let .onEditingChanged(text):
            let original = text.condenseWhitespace()
            let words = original.split(separator: " ")
            var hasError = false
            for word in words {
                if Mnemonic.search(prefix: String(word)).count == 0 {
                    hasError = true
                    break
                }
            }
            hasError = (words.count != 12)

            DispatchQueue.main.async {
                self.state.hasError = hasError

                let valid = Mnemonic.isValid(mnemonic: original)

                if text.last == " " || valid {
                    self.state.suggestions = []
                } else {
                    self.state.suggestions = Mnemonic.search(prefix: String(words.last ?? ""))
                }
                if words.count == 12 {
                    self.state.nextEnable = valid
                }
            }
        case .next:
            restoreLogin()
        case .confirmCreateWallet:
            createAccountWithCurrentMnemonic()
        }
    }

    private func getRawMnemonic() -> String {
        return state.text.condenseWhitespace()
    }

    private func restoreLogin() {
        UIApplication.shared.endEditing()
        
        HUD.loading()
        
        let mnemonic = getRawMnemonic()
        Task {
            do {
                try await UserManager.shared.restoreLogin(withMnemonic: mnemonic)
                
                DispatchQueue.main.async {
                    if let uid = UserManager.shared.activatedUID, MultiAccountStorage.shared.getBackupType(uid) == .none {
                        MultiAccountStorage.shared.setBackupType(.manual, uid: uid)
                    }
                }
                
                HUD.dismissLoading()
                HUD.success(title: "login_success".localized)
                Router.popToRoot()
            } catch LLError.accountNotFound {
                HUD.dismissLoading()
                DispatchQueue.main.async {
                    self.showCreateWalletAlertView()
                }
            } catch {
                HUD.dismissLoading()
                HUD.error(title: "login_failed".localized)
            }
        }
    }
    
    private func showCreateWalletAlertView() {
        withAnimation(.alertViewSpring) {
            self.state.isAlertViewPresented = true
        }
    }
    
    private func createAccountWithCurrentMnemonic() {
        let mnemonic = getRawMnemonic()
        Router.route(to: RouteMap.Register.root(mnemonic))
    }
}
