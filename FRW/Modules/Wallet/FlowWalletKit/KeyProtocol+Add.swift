//
//  KeyProtocol+Add.swift
//  FRW
//
//  Created by cat on 2024/9/27.
//

import Foundation
import FlowWalletKit

private let sTag = ".key."

enum KeyProvider {
    static func password(with _: String) -> String {
        let aseKey = LocalEnvManager.shared.backupAESKey
        return aseKey
    }

    static func lastKey(with uid: String, in store: FlowWalletKit.KeychainStorage ) -> String? {
        let allKeys = store.allKeys
        let result = allKeys.last { $0.contains(uid) }
        return result
    }

    static func getId(with key: String) -> String {
        guard key.contains(sTag) else {
            return key
        }
        guard let result = key.components(separatedBy: sTag).first else {
            return key
        }
        return result
    }
}

extension KeyProtocol {
    func createKey(uid: String) -> String {
        guard !uid.contains(sTag) else {
            return uid
        }
        let suffix = self.id.prefix(8)
        return uid + sTag + suffix
    }
}

