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
        let list: [MultiBackupManager.StoreItem] = []
        let newList = try await MultiBackupManager.shared.addNewMnemonic(on: .phrase, list: list, password: password)
        if let model = newList.first {
            let mnemonic = try MultiBackupManager.shared.decryptMnemonic(model.data, password: password)
        }
    }

    func getCurrentDriveItems() async throws -> [MultiBackupManager.StoreItem] {
        return []
    }

    func removeItem(password _: String) async throws {}
}
