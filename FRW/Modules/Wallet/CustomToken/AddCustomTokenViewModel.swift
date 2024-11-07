//
//  AddCustomTokenViewModel.swift
//  FRW
//
//  Created by cat on 10/30/24.
//

import Foundation
import UIKit
import web3swift
import BigInt
import Web3Core

class AddCustomTokenViewModel: ObservableObject {
    @Published var customAddress: String = ""
    
    func onPaste() {
        guard let address = UIPasteboard.general.string else {
            return
        }
        customAddress = address
    }
    
    func onSearch() {
        guard isValidAddress(address: customAddress) else {
            HUD.error(title: "invalid_address".localized)
            return
        }
        Task {
            do {
                HUD.loading()
                try await fetchInfo(by: customAddress)
                HUD.dismissLoading()
            } catch {
                HUD.error(title: "invalid_erc20".localized)
                log.error("[Add Custom Token] \(error.localizedDescription)")
                HUD.dismissLoading()
            }
        }
    }
    
    func isValidAddress(address: String) -> Bool {
        let result = address.lowercased().hasPrefix("0x")
        return result
    }
}

extension AddCustomTokenViewModel {
    func fetchInfo(by address: String) async throws {
        let manager = WalletManager.shared.customTokenManager
        let token = try await manager.findToken(evmAddress: address)
        guard let token = token else {
            return
        }
        Router.route(to: RouteMap.Wallet.showCustomToken(token))
    }
}

