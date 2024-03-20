//
//  EVMEnableViewModel.swift
//  FRW
//
//  Created by cat on 2024/2/26.
//

import SwiftUI

class EVMEnableViewModel: ObservableObject {
    func onSkip() {
        Router.pop()
    }
    
    func onClickEnable() {
        
        Task {
            do {
                HUD.loading()
                try await EVMAccountManager.shared.enableEVM()
                HUD.dismissLoading()
                Router.pop()
            }
            catch {
                HUD.dismissLoading()
                HUD.error(title: "Enable EVM failed.")
                log.error("Enable EVM failer: \(error)")
            }
        }
    }
    
    func onClickLearnMore() {
        
    }
}
