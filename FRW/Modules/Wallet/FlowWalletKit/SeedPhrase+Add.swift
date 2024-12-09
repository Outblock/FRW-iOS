//
//  SeedPhrase+Add.swift
//  FRW
//
//  Created by cat on 2024/9/27.
//

import Flow
import FlowWalletKit
import Foundation

extension SeedPhraseKey {
    private static let suffix = ".SP"
    static func wallet(id: String) throws -> SeedPhraseKey {
        let pw = KeyProvider.password(with: id)
        let key = KeyProvider.lastKey(with: id, in: seedPhraseStorage) ?? id
        let seedPhraseKey = try SeedPhraseKey.get(
            id: key,
            password: pw,
            storage: SeedPhraseKey.seedPhraseStorage
        )
        return seedPhraseKey
    }

    func store(id: String) throws {
        let pw = KeyProvider.password(with: id)
        let key = self.createKey(uid: id)
        try store(id: key, password: pw)
    }

    static var seedPhraseStorage: FlowWalletKit.KeychainStorage {
        let service = (Bundle.main.bundleIdentifier ?? AppBundleName) + suffix
        let storage = FlowWalletKit.KeychainStorage(
            service: service,
            label: "SeedPhraseKey",
            synchronizable: false
        )
        return storage
    }
}

//MARK: - For Backup
extension SeedPhraseKey {

    static func createBackup(uid: String? = nil) throws -> SeedPhraseKey {
        let key = try SeedPhraseKey.create(storage: seedPhraseBackupStorage)
        return key
    }

    func storeBackup(id: String) throws {
        let pw = KeyProvider.password(with: id)
        let key = self.createKey(uid: id)
        try store(id: key, password: pw)
    }

    static var seedPhraseBackupStorage: FlowWalletKit.KeychainStorage {
        let service = (Bundle.main.bundleIdentifier ?? AppBundleName) + suffix + ".backup"
        let storage = FlowWalletKit.KeychainStorage(
            service: service,
            label: "SeedPhraseKey Backup",
            synchronizable: false
        )
        return storage
    }
}
