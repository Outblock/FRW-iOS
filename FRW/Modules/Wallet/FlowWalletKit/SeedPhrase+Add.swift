//
//  SeedPhrase+Add.swift
//  FRW
//
//  Created by cat on 2024/9/27.
//

import Foundation
import FlowWalletKit
import Flow

extension SeedPhraseKey {
    
    static func wallet(id: String) throws -> SeedPhraseKey {
        let pw = KeyProvider.password(with: id)
        let seedPhraseKey = try SeedPhraseKey.get(id: id, password: pw, storage: SeedPhraseKey.seedPhraseStorage)
        return seedPhraseKey
    }
    
    static var seedPhraseStorage: FlowWalletKit.KeychainStorage {
        let service = (Bundle.main.bundleIdentifier ?? AppBundleName) + ".SP"
        let storage = FlowWalletKit.KeychainStorage(service: service, label: "SeedPhraseKey", synchronizable: false)
        return storage
    }
}

