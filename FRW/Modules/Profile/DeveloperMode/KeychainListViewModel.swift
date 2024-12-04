//
//  KeychainListViewModel.swift
//  FRW
//
//  Created by cat on 2024/4/26.
//

import FlowWalletKit
import Foundation
import KeychainAccess
import SwiftUI

class KeychainListViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        let remoteService = (Bundle.main.bundleIdentifier ?? "com.flowfoundation.wallet")
        self.remoteKeychain = Keychain(service: remoteService)
            .label("Lilico app backup")

        let localService = remoteService + ".local"
        self.localKeychain = Keychain(service: localService)
            .label("Flow Wallet Backup")

        self.seKeychain = Keychain(service: "com.flowfoundation.wallet.securekey")

        fecth()
    }

    // MARK: Internal

    @Published
    var localList: [[String: Any]] = []
    @Published
    var remoteList: [[String: Any]] = []
    @Published
    var seList: [[String: String]] = []
    @Published
    var multiICloudBackUpList: [[String: String]] = []

    func loadiCloudBackup() {
        Task {
            if let list = try? await MultiBackupManager.shared.getCloudDriveItems(from: .icloud) {
                DispatchQueue.main.async {
                    self.multiICloudBackUpList = list.map { [$0.userId: $0.publicKey] }
                }
            }
        }
    }

    func radomUpdatePrivateKey(index _: Int) {
        if isDevModel {
            // Modifying private key for test
        }
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
            if let decryptedData = try? WalletManager.decryptionChaChaPoly(key: uid, data: data),
               let mnemonic = String(
                   data: decryptedData,
                   encoding: .utf8
               ) {
                return mnemonic
            }
            return "decrypted failed"
        }

        return "not mnemonic"
    }

    // MARK: Private

    private let remoteKeychain: Keychain
    private let localKeychain: Keychain
    private let seKeychain: Keychain
    private let mnemonicPrefix = "lilico.mnemonic."

    private func fecth() {
        // fetch all key
    }
}
