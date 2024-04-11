//
//  EVMEnableViewModel.swift
//  FRW
//
//  Created by cat on 2024/2/26.
//

import SwiftUI

class EVMEnableViewModel: ObservableObject {
    @Published var state: VPrimaryButtonState = .enabled
    func onSkip() {
        Router.pop()
    }
    
    func onClickEnable() {
        
        Task {
            do {
                state = .loading
                try await EVMAccountManager.shared.enableEVM()
                EVMAccountManager.shared.refresh()
                state = .enabled
                Router.pop()
                ConfettiManager.show()
            }
            catch {
                state = .enabled
                HUD.error(title: "Enable EVM failed.")
                log.error("Enable EVM failer: \(error)")
            }
        }
    }
    
    func onClickLearnMore() {
        let evmUrl = "https://flow.com/upgrade/crescendo/evm"
        guard let url = URL(string: evmUrl) else { return }
        UIApplication.shared.open(url)
    }
}
