//
//  RestoreMultiAccountViewModel.swift
//  FRW
//
//  Created by cat on 2024/1/7.
//

import Foundation

class RestoreMultiAccountViewModel: ObservableObject {
    var items: [[MultiBackupManager.StoreItem]]

    init(items: [[MultiBackupManager.StoreItem]]) {
        self.items = items
    }

    func onClickUser(at index: Int) {
        guard index < items.count else {
            return
        }
        let selectedUser = items[index]
        
        
        // If it is the current user, do nothing and return directly.
        if let userId = UserManager.shared.activatedUID, let selectedUser = selectedUser.first, userId == selectedUser.userId {
            Router.popToRoot()
            return
        }
        // If it is in the login list, switch user
        if let userId = selectedUser.first?.userId, UserManager.shared.loginUIDList.contains(userId) {
            Task {
                do {
                    HUD.loading()
                    try await UserManager.shared.switchAccount(withUID: userId)
                    MultiAccountStorage.shared.setBackupType(.multi, uid: userId)
                    HUD.dismissLoading()
                } catch {
                    log.error("switch account failed", context: error)
                    HUD.dismissLoading()
                    HUD.error(title: error.localizedDescription)
                }
            }
            return
        }
         
        guard selectedUser.count > 1 else {
            return
        }
        Task {
            do {
                HUD.loading()
                try await MultiBackupManager.shared.addKeyToAccount(with: selectedUser)
                HUD.dismissLoading()
            }
            catch {
                log.error("add new device failed", context: error)
                HUD.dismissLoading()
                //TODO: des
                HUD.error(title: "restore failed")
            }
        }
    }
    
}
