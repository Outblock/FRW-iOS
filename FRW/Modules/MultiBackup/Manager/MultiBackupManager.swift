//
//  MultiBackupManager.swift
//  FRW
//
//  Created by cat on 2024/1/6.
//

import CryptoKit
import FirebaseAuth
import Flow
import FlowWalletCore
import Foundation
import GoogleAPIClientForREST_Drive
import GoogleAPIClientForRESTCore
import GoogleSignIn
import GTMSessionFetcherCore
import WalletCore

protocol MultiBackupTarget {
    var uploadedItem: MultiBackupManager.StoreItem? {get set}
    var registeredDeviceInfo: SyncInfo.DeviceInfo? {get set}
    func loginCloud() async throws
    func upload(password: String) async throws
    func getCurrentDriveItems() async throws -> [MultiBackupManager.StoreItem]
    func removeItem(password: String) async throws
}

class MultiBackupManager: ObservableObject {
    static let shared = MultiBackupManager()

    private let gdTarget = MultiBackupGoogleDriveTarget()
    private let iCloudTarget = MultiBackupiCloudTarget()
    private let phraseTarget = MultiBackupPhraseTarget()
    private let passkeyTarget = MultiBackupPasskeyTarget()
    private let password = LocalEnvManager.shared.backupAESKey
    static let backupFileName = "outblock_multi_backup"
    
    var deviceInfo: SyncInfo.DeviceInfo?
    var backupType: BackupType = .undefined
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(onTransactionManagerChanged), name: .transactionManagerDidChanged, object: nil)
    }
}

// MARK: - Data

extension MultiBackupManager {
    struct StoreItem: Codable {
        var address: String
        var userId: String
        var userName: String
        var userAvatar: String?
        var publicKey: String
        var data: String
        var keyIndex: Int
        var signAlgo: Int
        var hashAlgo: Int
        var weight: Int
        var updatedTime: Double? = Date.now.timeIntervalSince1970
        let deviceInfo: DeviceInfoRequest
        
        func showDate() -> String {
            guard let updatedTime = updatedTime else { return "" }
            let date = Date(timeIntervalSince1970: updatedTime)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd,yyyy"
            let res = dateFormatter.string(from: date)
            return res
        }
    }
}

// MARK: - Public

// MARK: - Steps to create a backup
extension MultiBackupManager {
    func registerKeyToChain(on type: MultiBackupType) async throws -> Bool {
        
        guard let username = UserManager.shared.userInfo?.username, !username.isEmpty else {
            throw BackupError.missingUserName
        }
        
        guard let uid = UserManager.shared.activatedUID, !uid.isEmpty else {
            throw BackupError.missingUid
        }
        
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            throw BackupError.missingMnemonic
        }
        
        guard let hdWallet = WalletManager.shared.createHDWallet(), let mnemonicData = hdWallet.mnemonic.data(using: .utf8) else {
            HUD.error(title: "empty_wallet_key".localized)
            throw BackupError.missingMnemonic
        }
        
        let dataHexString = try encryptMnemonic(mnemonicData, password: password)
        let publicKey = hdWallet.getPublicKey()
        
        let result =  try await addKeyToFlow(key: publicKey)
        if !result {
            return false
        }
        let keyIndex = try await fetchKeyIndex(publicKey: publicKey)
        
        // fetch ip info
        if IPManager.shared.info == nil {
            await IPManager.shared.fetch()
        }
        
        let flowPublicKey = Flow.PublicKey(hex: publicKey)
        let flowKey = Flow.AccountKey(publicKey: flowPublicKey, signAlgo: .ECDSA_SECP256k1, hashAlgo: .SHA2_256, weight: 500)
        let backupName = type.showName()
        let deviceInfo = SyncInfo.DeviceInfo(accountKey: flowKey.toCodableModel(), deviceInfo: IPManager.shared.toParams(), backupInfo: BackupInfoModel(create_time: nil, name: backupName, type: type.toBackupType().rawValue))
        
        let item = MultiBackupManager.StoreItem(
            address: address,
            userId: uid,
            userName: username,
            publicKey: publicKey,
            data: dataHexString,
            keyIndex: keyIndex,
            signAlgo: Flow.SignatureAlgorithm.ECDSA_P256.index,
            hashAlgo: Flow.HashAlgorithm.SHA2_256.index,
            weight: 500,
            deviceInfo: IPManager.shared.toParams()
        )
        updateTarget(on: type, item: item, deviceInfo: deviceInfo)
        return true
    }
    
    func backupKey(on type: MultiBackupType) async throws {
        switch type {
        case .google:
            backupType = .google
            try await gdTarget.loginCloud()
            try await gdTarget.upload(password: password)
        case .passkey:
            backupType = .passkey
            log.warning("not surport")
        case .icloud:
            backupType = .iCloud
            try await iCloudTarget.upload(password: password)
        case .phrase:
            backupType = .manual
            try await phraseTarget.upload(password: password)
        }
    }
    
    func syncKeyToServer(on type: MultiBackupType) async throws {
        guard let model = getTarget(with: type).registeredDeviceInfo else {
            return
        }
        do {
            let response: Network.EmptyResponse = try await Network.requestWithRawModel(FRWAPI.User.syncDevice(model))
            if response.httpCode != 200 {
                log.info("[MultiBackup] add device failed. publicKey: \(model.accountKey.publicKey)")
            }
        } catch {
            log.error("[sync account] error \(error.localizedDescription)")
        }
    }
}

// MARK: - Private,
extension MultiBackupManager {
    private func getTarget(with type: MultiBackupType) -> MultiBackupTarget {
        switch type {
        case .google:
            return gdTarget
        case .passkey:
            return passkeyTarget
        case .icloud:
            return iCloudTarget
        case .phrase:
            return phraseTarget
        }
    }
    
    private func updateTarget(on type:MultiBackupType, item: MultiBackupManager.StoreItem, deviceInfo: SyncInfo.DeviceInfo) {
        switch type {
        case .google:
            gdTarget.uploadedItem = item
            gdTarget.registeredDeviceInfo = deviceInfo
        case .passkey:
            passkeyTarget.uploadedItem = item
            passkeyTarget.registeredDeviceInfo = deviceInfo
        case .icloud:
            iCloudTarget.uploadedItem = item
            iCloudTarget.registeredDeviceInfo = deviceInfo
        case .phrase:
            phraseTarget.uploadedItem = item
            phraseTarget.registeredDeviceInfo = deviceInfo
        }
    }
    
    
}

extension MultiBackupManager {
    
    func getCloudDriveItems(from type: MultiBackupType) async throws -> [MultiBackupManager.StoreItem] {
        switch type {
        case .google:
            return try await gdTarget.getCurrentDriveItems()
        case .passkey:
            return []
        case .icloud:
            return try await iCloudTarget.getCurrentDriveItems()
        case .phrase:
            return []
        }
    }
    
    func login(from type: MultiBackupType) async throws {
        switch type {
        case .google:
            try await gdTarget.loginCloud()
        case .passkey:
            log.info("not finished")

        case .icloud:
            try await iCloudTarget.loginCloud()
            log.info("not finished")
        case .phrase:
            log.info("not finished")
        }
    }
    
    func removeItem(with type: MultiBackupType) async throws {
        let key = LocalEnvManager.shared.backupAESKey
        let password = key
        switch type {
        case .google:
            try await gdTarget.removeItem(password: password)
        case .passkey:
            log.info("not surport")
        case .icloud:
            try await iCloudTarget.removeItem(password: password)
        case .phrase:
            log.info("wait")
        }
    }
}

// MARK: - Helper

extension MultiBackupManager {
    
    /// append current user mnemonic to list
    func addNewMnemonic(on type: MultiBackupType, list: [MultiBackupManager.StoreItem], password: String) async throws -> [MultiBackupManager.StoreItem] {
        guard let uid = UserManager.shared.activatedUID, !uid.isEmpty else {
            throw BackupError.missingUid
        }
        guard let item = getTarget(with: type).uploadedItem else {
            throw BackupError.missingMnemonic
        }
        var newList = list
        if let i = list.firstIndex(where: { $0.userId == uid }) {
            newList.remove(at: i)
        }
        
        newList.append(item)
        return newList
    }
    
    
    func removeCurrent(_ list: [MultiBackupManager.StoreItem], password: String) async throws -> [MultiBackupManager.StoreItem] {
        guard let username = UserManager.shared.userInfo?.username, !username.isEmpty else {
            throw BackupError.missingUserName
        }
        
        guard let uid = UserManager.shared.activatedUID, !uid.isEmpty else {
            throw BackupError.missingUid
        }
        let res = list.filter { item in
            item.userId != uid && item.userName != username
        }
        return res
    }
    
    func iv() -> String {
        let key = LocalEnvManager.shared.backupAESKey
        let oldIV = LocalEnvManager.shared.aesIV
        guard let keyData = key.data(using: .utf8) else {
            return oldIV
        }
        let hashedKey = SHA256.hash(data: keyData).prefix(16)
        let hashData = Data(hashedKey)
        return String(data: hashData, encoding: .utf8) ?? oldIV
    }
    
    /// encrypt list to hex string
    func encryptList(_ list: [MultiBackupManager.StoreItem]) throws -> String {
        let jsonData = try JSONEncoder().encode(list)
        let iv = iv()
        let encrypedData = try WalletManager.encryptionAES(key: LocalEnvManager.shared.backupAESKey, iv: iv, data: jsonData)
        return encrypedData.hexString
    }
    
    /// decrypt hex string to list
    func decryptHexString(_ hexString: String) throws -> [MultiBackupManager.StoreItem] {
        guard let data = Data(hexString: hexString) else {
            throw BackupError.hexStringToDataFailed
        }
        
        return try decryptData(data)
    }
    
    private func decryptData(_ data: Data) throws -> [MultiBackupManager.StoreItem] {
        let iv = iv()
        let jsonData = try WalletManager.decryptionAES(key: LocalEnvManager.shared.backupAESKey, iv: iv, data: data)
        let list = try JSONDecoder().decode([MultiBackupManager.StoreItem].self, from: jsonData)
        return list
    }
    
    /// encrypt mnemonic data to hex string
    func encryptMnemonic(_ mnemonicData: Data, password: String) throws -> String {
        let iv = iv()
        let dataHexString = try WalletManager.encryptionAES(key: password, iv: iv, data: mnemonicData).hexString
        return dataHexString
    }
    
    /// decrypt hex string to mnemonic string
    func decryptMnemonic(_ hexString: String, password: String) throws -> String {
        guard let encryptData = Data(hexString: hexString) else {
            throw BackupError.hexStringToDataFailed
        }
        let iv = iv()
        let decryptedData = try WalletManager.decryptionAES(key: password, iv: iv, data: encryptData)
        guard let mm = String(data: decryptedData, encoding: .utf8), !mm.isEmpty else {
            throw BackupError.decryptMnemonicFailed
        }
        
        return mm
    }
}


extension MultiBackupManager {
    @objc private func onTransactionManagerChanged() {
        if TransactionManager.shared.holders.isEmpty {
            return
        }
    }
    
    private func addKeyToFlow(key: String) async throws -> Bool {
        let address = WalletManager.shared.address
        let accountKey = Flow.AccountKey(publicKey: Flow.PublicKey(hex: key), signAlgo: .ECDSA_SECP256k1, hashAlgo: .SHA2_256, weight: 500)
        let flowId = try await FlowNetwork.addKeyToAccount(address: address, accountKey: accountKey, signers: [WalletManager.shared, RemoteConfigManager.shared])
        guard let data = try? JSONEncoder().encode(key) else {
            return false
        }
        let holder = TransactionManager.TransactionHolder(id: flowId, type: .addToken, data: data)
        TransactionManager.shared.newTransaction(holder: holder)
        let result = try await flowId.onceSealed()
        if result.isFailed {
            return false
        }
        return true
    }
    
    func fetchKeyIndex(publicKey: String) async throws -> Int {
        let address = WalletManager.shared.getPrimaryWalletAddress() ?? ""
        let accounts = try await FlowNetwork.getAccountAtLatestBlock(address: address)
        let model = accounts.keys.first { $0.publicKey.description == publicKey }
        guard let accountModel = model else {
            return 0
        }
        return accountModel.index
    }
    
}

extension MultiBackupManager {
    func addKeyToAccount(with list: [MultiBackupManager.StoreItem]) async throws {
        guard list.count > 1 else {
            return
        }
        
        var firstItem = list[0]
        var secondItem = list[1]
        let addressDes = list[0].address
        
        let account = try await FlowNetwork.getAccountAtLatestBlock(address: addressDes)
        var sequenNum: Int64 = 0
        account.keys.forEach { accountKey in
            let publicKey = accountKey.publicKey.description
            if publicKey == firstItem.publicKey {
                sequenNum = accountKey.sequenceNumber
                firstItem.keyIndex = accountKey.index
            }
            if publicKey == secondItem.publicKey {
                secondItem.keyIndex = accountKey.index
            }
        }
        
        let firstSigner = MultiBackupManager.Signer(provider: firstItem)
        let secondSigner = MultiBackupManager.Signer(provider: secondItem)
        
        let address = Flow.Address(hex: addressDes)
        
        let sec = try WallectSecureEnclave()
        let key = try sec.accountKey()
        do {
            HUD.loading()
            let tx = try await FlowNetwork.addKeyWithMulti(address: address, keyIndex: firstItem.keyIndex, sequenceNum: sequenNum, accountKey: key, signers: [firstSigner, secondSigner, RemoteConfigManager.shared])
            let firstKeySignature = AccountKeySignature(hashAlgo: firstSigner.hashAlgo.index, publicKey: firstSigner.provider.publicKey, signAlgo: firstSigner.signatureAlgo.index, signMessage: "", signature: firstSigner.signature?.hexValue ?? "", weight: firstSigner.provider.signAlgo)
            let secondKeySignature = AccountKeySignature(hashAlgo: secondSigner.hashAlgo.index, publicKey: secondSigner.provider.publicKey, signAlgo: secondSigner.signatureAlgo.index, signMessage: "", signature: secondSigner.signature?.hexValue ?? "", weight: secondSigner.provider.signAlgo)
            let request = SignedRequest(accountKey: AccountKey(hashAlgo: key.hashAlgo.index,
                                                               publicKey: key.publicKey.description,
                                                               signAlgo: key.signAlgo.index,
                                                               weight: key.weight),
                                        signatures: [firstKeySignature, secondKeySignature])
            let response: Network.EmptyResponse = try await Network.requestWithRawModel(FRWAPI.User.addSigned(request))
            if response.httpCode != 200 {
                log.info("[Multi-backup] sync failed")
            } else {
                print("")
                if let privateKey = sec.key.privateKey {
                    try WallectSecureEnclave.Store.store(key: firstItem.userId, value: privateKey.dataRepresentation)
                }
                
                try await UserManager.shared.restoreLogin(userId: firstItem.userId)
                Router.popToRoot()
            }
            HUD.dismissLoading()
            
            print(tx)
        } catch {
            HUD.dismissLoading()
            print(error)
        }
    }
}

// MARK: - Signer

extension MultiBackupManager {
    class Signer: FlowSigner {
        let provider: MultiBackupManager.StoreItem
        var signature: Data?
        
        init(provider: MultiBackupManager.StoreItem) {
            self.provider = provider
        }
        
        public var address: Flow.Address {
            return Flow.Address(hex: provider.address)
        }
        
        public var hashAlgo: Flow.HashAlgorithm {
            .SHA2_256
        }
        
        public var signatureAlgo: Flow.SignatureAlgorithm {
            .ECDSA_SECP256k1
        }
        
        public var keyIndex: Int {
            provider.keyIndex
        }
        
        public func sign(transaction: Flow.Transaction, signableData: Data) async throws -> Data {
            let key = LocalEnvManager.shared.backupAESKey
            let mnemonic = try MultiBackupManager.shared.decryptMnemonic(provider.data, password: key)
            
            guard let hdWallet = WalletManager.shared.createHDWallet(mnemonic: mnemonic) else {
                throw BackupError.missingMnemonic
            }
            
            var privateKey = hdWallet.getKeyByCurve(curve: .secp256k1, derivationPath: WalletManager.flowPath)
            let hashedData = Hash.sha256(data: signableData)
            
            defer {
                privateKey = PrivateKey()
            }
            
            guard var signature = privateKey.sign(digest: hashedData, curve: .secp256k1) else {
                throw LLError.signFailed
            }
            
            signature.removeLast()
            
            return signature
            
//            let sec = try WallectSecureEnclave(privateKey: data)
//            let signature = try sec.sign(data: signableData)
//            self.signature = signature
//            return signature
        }
    }
}
