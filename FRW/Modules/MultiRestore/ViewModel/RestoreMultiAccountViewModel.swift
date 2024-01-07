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
        guard selectedUser.count > 1 else {
            return
        }
        let firstItem = selectedUser[0]
        let secondItem = selectedUser[1]
        log.info(firstItem)
    }
}
