//
//  KeychainListViewModel.swift
//  FRW
//
//  Created by cat on 2024/4/26.
//

import Foundation
import KeychainAccess
import SwiftUI
import FlowWalletCore

class KeychainListViewModel: ObservableObject {
    @Published var localList: [[String: Any]] = []
    @Published var remoteList: [[String: Any]] = []
    @Published var seList: [[String: String]] = []
    @Published var multiICloudBackUpList: [[String: String]]  = []

    private let remoteKeychain: Keychain
    private let localKeychain: Keychain
    private let seKeychain: Keychain
    private let mnemonicPrefix = "lilico.mnemonic."

    init() {
        let remoteService = (Bundle.main.bundleIdentifier ?? "com.flowfoundation.wallet")
        remoteKeychain = Keychain(service: remoteService)
            .label("Lilico app backup")

        let localService = remoteService + ".local"
        localKeychain = Keychain(service: localService)
            .label("Flow Wallet Backup")
        
        seKeychain = Keychain(service: "com.flowfoundation.wallet.securekey")
        
        fecth()
    }

    private func fecth() {
        remoteList = remoteKeychain.allItems()
        loadiCloudBackup()
        if let item = remoteList.last {
            log.info(item)
        }
        localList = localKeychain.allItems()
        do {
            guard let data = try seKeychain.getData("user.keystore") else {
                return
            }
            let users = try? JSONDecoder().decode([WallectSecureEnclave.StoreInfo].self, from: data)
            seList = users?.map({ info in
                
                if let sec = try? WallectSecureEnclave(privateKey: info.publicKey), let publicKey = sec.key.publickeyValue {
                    return [info.uniq: publicKey]
                }else {
                    return [info.uniq: "undefined"]
                }
                
            }) ?? []
        }catch {
            log.error("[kc] fetch failed. \(error)")
        }
    }
    
    func loadiCloudBackup() {
        Task {
            if let list = try? await MultiBackupManager.shared.getCloudDriveItems(from: .icloud) {
                DispatchQueue.main.async {
                    self.multiICloudBackUpList = list.map{ [$0.userId : $0.publicKey] }
                }
            }
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
            if let decryptedData = try? WalletManager.decryptionChaChaPoly(key: uid, data: data), let mnemonic = String(data: decryptedData, encoding: .utf8) {
                return mnemonic
            }
            return "decrypted failed"
        }

        return "not mnemonic"
    }
}
