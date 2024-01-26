//
//  MultiBackupPhraseTarget.swift
//  FRW
//
//  Created by cat on 2024/1/8.
//

import Foundation

class MultiBackupPhraseTarget: MultiBackupTarget {
    var uploadedItem: MultiBackupManager.StoreItem?
    
    var registeredDeviceInfo: SyncInfo.DeviceInfo?
    
    func loginCloud() async throws {}
    
    var isPrepared: Bool {
        return true
    }
    
    func upload(password: String) async throws {
        let list:[MultiBackupManager.StoreItem] = []
        let newList = try await MultiBackupManager.shared.addCurrentMnemonicToList(list, password: password)
        if let model = newList.first {
            let key = LocalEnvManager.shared.backupAESKey
            let mnemonic = try MultiBackupManager.shared.decryptMnemonic(model.data, password: key)
            Router.route(to: RouteMap.Backup.showPhrase(mnemonic))
        }
    }
    
    func getCurrentDriveItems() async throws -> [MultiBackupManager.StoreItem] {
        return []
    }
    
    func removeItem(password: String) async throws {}
}
