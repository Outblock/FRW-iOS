//
//  RestoreMultiInputMnemonicViewModel.swift
//  FRW
//
//  Created by cat on 2024/1/8.
//

import Foundation
import SwiftUI
import WalletCore

class RestoreMultiInputMnemonicViewModel: ObservableObject {
    // MARK: Internal

    @Published
    var nextEnable: Bool = false
    @Published
    var hasError: Bool = false
    @Published
    var suggestions: [String] = []
    @Published
    var text: String = ""
    @Published
    var isAlertViewPresented: Bool = false

    func onEditingChanged(text: String) {
        let original = text.condenseWhitespace()
        let words = original.split(separator: " ")
        var hasError = false
        for word in words {
            if Mnemonic.search(prefix: String(word)).isEmpty {
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
        text.condenseWhitespace()
    }

    // MARK: Private

    private func showCreateWalletAlertView() {
        withAnimation(.alertViewSpring) {
            self.isAlertViewPresented = true
        }
    }
}
