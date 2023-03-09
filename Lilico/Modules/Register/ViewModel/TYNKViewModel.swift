//
//  TYNKViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 3/1/22.
//

import Foundation
import Resolver


class TYNKViewModel: ViewModel {
    @Published private(set) var state = TYNKView.ViewState()
    var username: String
    var mnemonic: String?

    init(username: String, mnemonic: String?) {
        self.username = username
        self.mnemonic = mnemonic
    }

    func trigger(_ input: TYNKView.Action) {
        switch input {
        case .createWallet:
            registerAction()
        }
    }
    
    func registerAction() {
        state.isLoading = true
        
        Task {
            do {
                try await UserManager.shared.register(username, mnemonic: mnemonic)
                HUD.success(title: "create_user_success".localized)
                
                DispatchQueue.main.async {
                    self.state.isLoading = false
                    Router.route(to: RouteMap.Backup.rootWithMnemonic)
                }
            } catch {
                DispatchQueue.main.async {
                    self.state.isLoading = false
                    HUD.error(title: "create_user_failed".localized)
                }
            }
        }
    }
}
