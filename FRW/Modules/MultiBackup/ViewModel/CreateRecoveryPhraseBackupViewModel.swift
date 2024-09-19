//
//  CreateRecoveryPhraseBackupViewModel.swift
//  FRW
//
//  Created by cat on 2024/9/19.
//

import Foundation
import UIKit
import WalletCore
import Flow
import KeychainAccess

class CreateRecoveryPhraseBackupViewModel: ObservableObject {
    @Published var mnemonic: String = ""
    @Published var isBlur: Bool = false
    
    private var hdWallet: HDWallet?
    private let mnemonicStrength: Int32 = 128
    private let store = PhraseKeyStore()
    
    var dataSource: [WordListView.WordItem] {
        mnemonic.split(separator: " ").enumerated().map { item in
            WordListView.WordItem(id: item.offset + 1, word: String(item.element))
        }
    }
    
    init() {
        hdWallet = HDWallet(strength: mnemonicStrength, passphrase: "")
        mnemonic = hdWallet?.mnemonic ?? ""
    }
    
    func onCreate() {
        guard let hdWallet = hdWallet else {
            HUD.error(title: "fetch public key failed.")
            return
        }
        HUD.loading()
        Task {
            do {
                let addStatus = try await addKeyToFlow(hdWallet: hdWallet)
                if !addStatus {
                    HUD.error(title: "add key failed.")
                    return
                }
                try await addKeyToService(hdWallet: hdWallet)
                try addKeyToLocal(hdWallet: hdWallet)
                DispatchQueue.main.async {
                    HUD.dismissLoading()
                    Router.route(to: RouteMap.Backup.backupCompleted(hdWallet.mnemonic))
                }
            }catch {
                HUD.error(title: "\(error.localizedDescription)")
                DispatchQueue.main.async {
                    HUD.dismissLoading()
                }
            }
        }
    }
    
    private func addKeyToFlow(hdWallet: HDWallet) async throws -> Bool {
        
        let publicKey = hdWallet.getPublicKey()
        let address = WalletManager.shared.address
        
        let flowKey = flowKey(with: publicKey)
        let flowId = try await FlowNetwork.addKeyToAccount(address: address, accountKey: flowKey, signers: WalletManager.shared.defaultSigners)
        guard let data = try? JSONEncoder().encode(publicKey) else {
            return false
        }
        let holder = TransactionManager.TransactionHolder(id: flowId, type: .common, data: data)
        TransactionManager.shared.newTransaction(holder: holder)
        let result = try await flowId.onceSealed()
        if result.isFailed {
            return false
        }
        return true
    }
    
    private func addKeyToService(hdWallet: HDWallet) async throws {
        
        let publicKey = hdWallet.getPublicKey()
        let type = BackupType.fullWeightSeedPhrase
        let backupName = type.title
        
        let flowKey = flowKey(with: publicKey)
        let deviceInfo = SyncInfo.DeviceInfo(accountKey: flowKey.toCodableModel(), deviceInfo: IPManager.shared.toParams(), backupInfo: BackupInfoModel(createTime: nil, name: backupName, type: type.rawValue))
        
        
        do {
            let response: Network.EmptyResponse = try await Network.requestWithRawModel(FRWAPI.User.syncDevice(deviceInfo))
            if response.httpCode != 200 {
                log.info("sync key to server failed.\(response.httpCode): \(response.message)")
            }
        } catch {
            log.error("sync account error \(error.localizedDescription)")
        }
    }
    
    private func flowKey(with publicKey: String) -> Flow.AccountKey {
        let flowPublicKey = Flow.PublicKey(hex: publicKey)
        let flowKey = Flow.AccountKey(publicKey: flowPublicKey, signAlgo: .ECDSA_SECP256k1, hashAlgo: .SHA2_256, weight: 1000)
        return flowKey
    }
    
    private func fetchKeyIndex(publicKey: String) async throws -> Int {
        let address = WalletManager.shared.getPrimaryWalletAddress() ?? ""
        let accounts = try await FlowNetwork.getAccountAtLatestBlock(address: address)
        let model = accounts.keys.first { $0.publicKey.description == publicKey }
        guard let accountModel = model else {
            return 0
        }
        return accountModel.index
    }
    
    private func addKeyToLocal(hdWallet: HDWallet) throws {
        guard let uid = UserManager.shared.activatedUID else {
            throw BackupError.missingUid
        }
        try? store.addMnemonic(mnemonic: hdWallet.mnemonic, userId: uid)
    }
    
    
    func onCopy() {
        guard !mnemonic.isEmpty else {
            return
        }
        UIPasteboard.general.string = mnemonic
        HUD.success(title: "copied".localized)
    }
}
