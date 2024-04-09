//
//  RestoreMultiInputMnemonicViewModel.swift
//  FRW
//
//  Created by cat on 2024/1/8.
//

import Foundation
import WalletCore
import SwiftUI

class RestoreMultiInputMnemonicViewModel: ObservableObject {
    
    @Published var nextEnable: Bool = false
    @Published var hasError: Bool = false
    @Published var suggestions: [String] = []
    @Published var text: String = ""
    @Published var isAlertViewPresented: Bool = false
    
    func onEditingChanged(text: String) {
        let original = text.condenseWhitespace()
        let words = original.split(separator: " ")
        var hasError = false
        for word in words {
            if Mnemonic.search(prefix: String(word)).count == 0 {
                hasError = true
                break
            }
        }

        DispatchQueue.main.async {
            self.hasError = hasError

            let valid = Mnemonic.isValid(mnemonic: original)

            if text.last == " " || valid {
                self.suggestions = []
            } else {
                self.suggestions = Mnemonic.search(prefix: String(words.last ?? ""))
            }
            self.nextEnable = valid
        }
    }

    func getRawMnemonic() -> String {
        return text.condenseWhitespace()
    }
    
    private func showCreateWalletAlertView() {
        withAnimation(.alertViewSpring) {
            self.isAlertViewPresented = true
        }
    }

}
