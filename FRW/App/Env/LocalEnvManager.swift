//
//  LocalEnvManager.swift
//  Flow Wallet
//
//  Created by Selina on 23/2/2023.
//

import Foundation

class LocalEnvManager {
    static let shared = LocalEnvManager()
    private let dict: [String: String]

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
}

extension LocalEnvManager {
    var backupAESKey: String {
        return dict["BackupAESKey"]!
    }

    var walletConnectProjectID: String {
        return dict["WalletConnectProjectID"]!
    }

    var aesIV: String {
        return dict["AESIV"]!
    }
}
