//
//  File.swift
//  FRW
//
//  Created by cat on 2024/9/10.
//

import Foundation
import FlowWalletKit
import Flow

extension PKWallet {
    
    
    func store(id: String ) throws {
        let pw = PKWallet.password(by: id)
        try store(id: id, password: pw)
    }
}

extension PKWallet {
    static var PKStorage: FlowWalletKit.PrivateKeyStorage {
        let service = (Bundle.main.bundleIdentifier ?? AppBundleName) + ".PK"
        let storage = FlowWalletKit.PrivateKeyStorage(service: service, label: "PKWallet")
        return storage
    }
    
    static func password(by id: String) -> String {
        let aseKey = LocalEnvManager.shared.backupAESKey
        return aseKey
    }
}
