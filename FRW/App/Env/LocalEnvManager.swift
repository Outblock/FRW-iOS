//
//  LocalEnvManager.swift
//  Flow Wallet
//
//  Created by Selina on 23/2/2023.
//

import Foundation

// MARK: - LocalEnvManager

class LocalEnvManager {
    // MARK: Lifecycle

    init() {
        do {
            let path = Bundle.main.url(forResource: "LocalEnv", withExtension: nil)!
            let data = try Data(contentsOf: path)
            let dict = try JSONDecoder().decode([String: String].self, from: data)
            self.dict = dict
        } catch {
            fatalError("LocalEnvManager init failed")
        }
    }

    // MARK: Internal

    static let shared = LocalEnvManager()

    // MARK: Private

    private let dict: [String: String]
}

extension LocalEnvManager {
    var backupAESKey: String {
        dict["BackupAESKey"]!
    }

    var walletConnectProjectID: String {
        dict["WalletConnectProjectID"]!
    }

    var aesIV: String {
        dict["AESIV"]!
    }
}
