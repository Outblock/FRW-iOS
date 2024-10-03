//
//  KeychainListViewModel.swift
//  FRW
//
//  Created by cat on 2024/4/26.
//

import Foundation
import KeychainAccess
import SwiftUI

class KeychainListViewModel: ObservableObject {
    @Published var localList: [[String: Any]] = []
    @Published var remoteList: [[String: Any]] = []

    private let remoteKeychain: Keychain
    private let localKeychain: Keychain
    private let mnemonicPrefix = "lilico.mnemonic."

    init() {
        let remoteService = (Bundle.main.bundleIdentifier ?? "com.flowfoundation.wallet")
        remoteKeychain = Keychain(service: remoteService)
            .label("Lilico app backup")

        let localService = remoteService + ".local"
        localKeychain = Keychain(service: localService)
            .label("Flow Wallet Backup")
        fecth()
    }

    private func fecth() {
        guard isDevModel, let bundleId = Bundle.main.bundleIdentifier, bundleId.hasSuffix(".dev") else {
            return
        }
        remoteList = remoteKeychain.allItems()
        if let item = remoteList.last {
            log.info(item)
        }
        localList = localKeychain.allItems()
        print(remoteList)
    }

    func getKey(item: [String: Any]) -> String {
        guard let key = item["key"] as? String else {
            return "not found key"
        }
        return key.removedPrefix(mnemonicPrefix)
    }

    func mnemonicValue(item: [String: Any]) -> String {
        guard let key = item["key"] as? String, let value = item["value"] else {
            return "error item"
        }

        if key.contains(mnemonicPrefix), let data = value as? Data {
            let uid = key.removePrefix(mnemonicPrefix)
            if let decryptedData = try? WalletManager.decryptionChaChaPoly(key: uid, data: data), let mnemonic = String(data: decryptedData, encoding: .utf8) {
                return mnemonic
            }
            return "decrypted failed"
        }

        return "not mnemonic"
    }
}
