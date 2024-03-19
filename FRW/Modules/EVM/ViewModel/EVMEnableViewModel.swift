//
//  EVMEnableViewModel.swift
//  FRW
//
//  Created by cat on 2024/2/26.
//

import SwiftUI

class EVMEnableViewModel: ObservableObject {
    func onSkip() {}
    
    func onClickEnable() {
        Task {
            do {
                try await EVMAccountManager.shared.enableEVM()
            }
            catch {
                log.error("Enable EVM failer: \(error)")
            }
        }
    }
    
    func onClickLearnMore() {}
}
