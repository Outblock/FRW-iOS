//
//  UserManager.swift
//  Flow Wallet
//
//  Created by Hao Fu on 30/12/21.
//

import Alamofire
import Combine
import Firebase
import FirebaseAuth
import Flow
import FlowWalletKit
import Foundation

import Alamofire
import WalletCore

// MARK: - UserManager.UserType

extension UserManager {
    enum UserType: Codable {
        case phrase
        case secure
        case fromImport
    }
}

// MARK: - UserManager

class UserManager: ObservableObject {
    // MARK: Lifecycle

    init() {
        checkIfHasOldAccount()

        self.loginUIDList = LocalUserDefaults.shared.loginUIDList

        if let activatedUID = activatedUID {
            self.userInfo = MultiAccountStorage.shared.getUserInfo(activatedUID)
            uploadUserNameIfNeeded()
            initRefreshUserInfo()
            verifyUserType(by: activatedUID)
        }

        loginAnonymousIfNeeded()
    }

    // MARK: Internal

    static let shared = UserManager()

    @Published
    var isMeowDomainEnabled: Bool = false

    var userType: UserManager.UserType = .secure

    @Published
    var activatedUID: String? = LocalUserDefaults.shared.activatedUID {
        didSet {
            LocalUserDefaults.shared.activatedUID = activatedUID
            if oldValue != activatedUID {
                clearWhenUserChanged()
            }
        }
    }

    @Published
    var userInfo: UserInfo? {
        didSet {
            do {
                guard let uid = activatedUID else { return }
                try MultiAccountStorage.shared.saveUserInfo(userInfo, uid: uid)
            } catch {
                log.error("save user info failed", context: error)
            }
        }
    }

    @Published
    var loginUIDList: [String] = [] {
        didSet {
            LocalUserDefaults.shared.loginUIDList = loginUIDList
        }
    }

    var isLoggedIn: Bool {
        activatedUID != nil
    }

    func verifyUserType(by _: String) {
        Task {
            do {
                userType = try await checkUserType()
                if let uid = activatedUID {
                    WalletManager.shared.warningIfKeyIsInvalid(userId: uid)
                }
            } catch {
                log.error("[User] check user type:\(error)")
            }
        }
    }

    // MARK: Private

    private func initRefreshUserInfo() {
        if !isLoggedIn {
            return
        }

        guard let uid = activatedUID else { return }

        Task {
            do {
                var info = try await self.fetchUserInfo()
                info.type = self.userInfo?.type
                let userInfo = info
                if activatedUID != uid { return }

                DispatchQueue.main.async {
                    self.userInfo = userInfo
                }

                self.fetchMeowDomainStatus(info.username)
            } catch {
                log.error("init refresh user info failed", context: error)
            }
        }
    }

    private func checkIfHasOldAccount() {
        if LocalUserDefaults.shared.tryToRestoreAccountFlag == true {
            return
        }
    }

    private func checkUserType() async throws -> UserManager.UserType {
        guard let address = WalletManager.shared.getPrimaryWalletAddress(),
              let uid = activatedUID else { return .secure }

        let account = try await FlowNetwork.getAccountAtLatestBlock(address: address)

        if let mnemonic = WalletManager.shared.getMnemonicFromKeychain(uid: uid),
           !mnemonic.isEmpty {
            let hdWallet = WalletManager.shared.createHDWallet(mnemonic: mnemonic)
            let accountKeys = account.keys
                .first { $0.publicKey.description == hdWallet?.getPublicKey() }
            if accountKeys != nil {
                return .phrase
            }
        }
        return .secure
    }

    private func clearWhenUserChanged() {
        BrowserViewController.deleteCookie()
    }
}

// MARK: - Reset

extension UserManager {
    func reset() async throws {
        log.debug("reset start")

        guard let willResetUID = activatedUID else {
            log.warning("willResetUID is nil")
            return
        }

        try await Auth.auth().signInAnonymously()

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .willResetWallet)

            self.activatedUID = nil
            self.userInfo = nil
            self.deleteLoginUID(willResetUID)

            NotificationCenter.default.post(name: .didResetWallet)

            Router.popToRoot()
        }
    }
}

// MARK: - Register

extension UserManager {
    func register(_ userName: String) async throws -> String? {
        if Auth.auth().currentUser?.isAnonymous != true {
            try await Auth.auth().signInAnonymously()
            DispatchQueue.main.async {
                self.activatedUID = nil
                self.userInfo = nil
            }
        }

        let secureKey = try SecureEnclaveKey.create()
        let key = try secureKey.flowAccountKey(index: 0)
        if IPManager.shared.info == nil {
            await IPManager.shared.fetch()
        }
        let request = RegisterRequest(
            username: userName,
            accountKey: key.toCodableModel(),
            deviceInfo: IPManager.shared.toParams()
        )
        let model: RegisterResponse = try await Network.request(FRWAPI.User.register(request))

        try secureKey.store(id: model.id)
        let store = UserManager.StoreUser(
            publicKey: key.publicKey.description,
            address: nil,
            userId: model.id,
            keyType: .secureEnclave,
            account: key.toStoreKey()
        )
        WalletManager.shared.updateKeyProvider(provider: secureKey, storeUser: store)
        LocalUserDefaults.shared.addUser(user: store)

        try await finishLogin(mnemonic: "", customToken: model.customToken, isRegiter: true)
        WalletManager.shared.asyncCreateWalletAddressFromServer()
        userType = .secure

        EventTrack.Account
            .create(
                key: key.publicKey.description,
                signAlgo: key.signAlgo.id,
                hashAlgo: key.hashAlgo.id
            )
        return model.txId
    }
}

// MARK: - Restore Login

extension UserManager {
    func hasOldAccount() -> Bool {
        if let user = Auth.auth().currentUser, !user.isAnonymous {
            return true
        }

        return false
    }

    func tryToRestoreOldAccountOnFirstLaunch() {
        HUD.loading()
        Task {
            do {
                var addressList: [String: String] = [:]
                //Secure Enclave Key
                let seKeylist = SecureEnclaveKey.KeychainStorage.allKeys
                for key in seKeylist {
                    if let se = try? SecureEnclaveKey.wallet(id: key),
                       let publicKey = try? se.publicKey()?.hexValue {
                        let response: AccountResponse = try await Network
                            .requestWithRawModel(FRWAPI.Utils.flowAddress(publicKey))
                        let account = response.accounts?
                            .filter { ($0.weight ?? 0) >= 1000 && $0.address != nil }.first
                        if let model = account {
                            addressList[key] = model.address ?? "0x"
                            let userId = KeyProvider.getId(with: key)
                            let storeUser = UserManager.StoreUser(publicKey: publicKey, address: nil, userId: userId, keyType: .secureEnclave, account: nil)
                            LocalUserDefaults.shared.addUser(user: storeUser)
                        }
                    } else {
                        log.error("[Launch] first login check failed:\(key)")
                    }
                }
                //
                let spKeyList = SeedPhraseKey.seedPhraseStorage.allKeys
                for key in spKeyList {
                    do {
                        guard let provider = try? SeedPhraseKey.wallet(id: key) else {
                            log.error("[Launch] seed phrase restore failed.\(key): not found")
                            continue
                        }
                        guard let publicKey = try? provider.publicKey(signAlgo: .ECDSA_SECP256k1)?.hexString else {
                            log.error("[Launch] seed phrase restore failed.\(key): public key")
                            continue
                        }
                        let response: AccountResponse = try await Network
                            .requestWithRawModel(FRWAPI.Utils.flowAddress(publicKey))
                        let account = response.accounts?
                            .filter { ($0.weight ?? 0) >= 1000 && $0.address != nil }.first
                        if let model = account {
                            addressList[key] = model.address ?? "0x"
                            let userId = KeyProvider.getId(with: key)
                            let storeUser = UserManager.StoreUser(publicKey: publicKey, address: nil, userId: userId, keyType: .seedPhrase, account: nil)
                            LocalUserDefaults.shared.addUser(user: storeUser)
                        } else {
                            log.error("[Launch] seed phrase not found account:\(key)")
                        }
                    } catch {
                        log.error("[Launch] seed phrase restore failed.\(key):\(error)")
                        continue
                    }
                }

                let pkKeyList = FlowWalletKit.PrivateKey.PKStorage.allKeys
                for key in pkKeyList {
                    do {
                        guard let provider = try? FlowWalletKit.PrivateKey.wallet(id: key) else {
                            log.error("[Launch] Private key restore failed.\(key): not found")
                            continue
                        }
                        let secpPublicKey = try? provider.publicKey(signAlgo: .ECDSA_SECP256k1)?.hexString
                        let p256PublicKey = try? provider.publicKey(signAlgo: .ECDSA_P256)?.hexString
                        let suffix = KeyProvider.getSuffix(with: key)
                        var storePublicKey: String?
                        if let publicKey = secpPublicKey, publicKey.hasPrefix(suffix) {
                            storePublicKey = publicKey
                        }
                        if let publicKey = p256PublicKey, publicKey.hasPrefix(suffix) {
                            storePublicKey = publicKey
                        }
                        guard let publicKey = storePublicKey else {
                            continue
                        }
                        let response: AccountResponse = try await Network
                            .requestWithRawModel(FRWAPI.Utils.flowAddress(publicKey))
                        let account = response.accounts?
                            .filter { ($0.weight ?? 0) >= 1000 && $0.address != nil }.first
                        if let model = account {
                            addressList[key] = model.address ?? "0x"
                            let userId = KeyProvider.getId(with: key)
                            let storeUser = UserManager.StoreUser(publicKey: publicKey, address: nil, userId: userId, keyType: .privateKey, account: nil)
                            LocalUserDefaults.shared.addUser(user: storeUser)
                        } else {
                            log.error("[Launch] Private key not found account:\(key)")
                        }

                    } catch {
                        log.error("[Launch] Private key restore failed.\(key):\(error)")
                        continue
                    }
                }

                var result: [String: String] = [:]
                for (key,value) in addressList {
                    let userId = KeyProvider.getId(with: key)
                    result[userId] = value
                }
                let uidList = result.map { $0.key }
                let userAddress = result
                DispatchQueue.main.async {
                    LocalUserDefaults.shared.userAddressOfDeletedApp = userAddress
                    LocalUserDefaults.shared.tryToRestoreAccountFlag = true
                    self.loginUIDList = uidList
                }

                HUD.dismissLoading()
            } catch {
                HUD.dismissLoading()
                log.info("restore old failed:\(error)")
            }
        }
    }

    func restoreLogin(withMnemonic mnemonic: String, userId: String? = nil) async throws {
        if let uid = userId {
            if let address = MultiAccountStorage.shared.getWalletInfo(uid)?
                .currentNetworkWalletModel?.getAddress {
                try? await WalletManager.shared.findFlowAccount(with: uid, at: address)
            }
        }

        if Auth.auth().currentUser?.isAnonymous != true {
            try await Auth.auth().signInAnonymously()
            DispatchQueue.main.async {
                self.activatedUID = nil
                self.userInfo = nil
            }
        }

        guard let token = try? await getIDToken(), !token.isEmpty else {
            loginAnonymousIfNeeded()
            throw LLError.restoreLoginFailed
        }

        guard let hdWallet = HDWallet(mnemonic: mnemonic, passphrase: "") else {
            throw WalletError.mnemonicMissing
        }

        let provider = FlowWalletKit.SeedPhraseKey(hdWallet: hdWallet, storage: FlowWalletKit.SeedPhraseKey.seedPhraseStorage) 
        let secpPublicKey = try provider.publicKey(signAlgo: .ECDSA_SECP256k1)
        guard var publicKey = secpPublicKey?.hexString else {
            throw WalletError.emptyPublicKey
        }

        guard var signature = provider.hdWallet.sign(token) else {
            throw LLError.signFailed
        }

        userType = .phrase
        await IPManager.shared.fetch()
        let hashAlgo = Flow.HashAlgorithm.SHA2_256.index
        let signAlgo = Flow.SignatureAlgorithm.ECDSA_SECP256k1.index
        let key = AccountKey(
            hashAlgo: hashAlgo,
            publicKey: publicKey,
            signAlgo: signAlgo
        )

        let request = LoginRequest(
            signature: signature,
            accountKey: key,
            deviceInfo: IPManager.shared.toParams()
        )
        let response: Network.Response<LoginResponse> = try await Network
            .requestWithRawModel(FRWAPI.User.login(request))
        if response.httpCode == 404 {
            throw LLError.accountNotFound
        }

        guard let customToken = response.data?.customToken, !customToken.isEmpty, let uid = response.data?.id else {
            throw LLError.restoreLoginFailed
        }
        let storeUser = StoreUser(
            publicKey: publicKey,
            address: nil,
            userId: uid,
            keyType: provider.keyType,
            account: nil
        )
        LocalUserDefaults.shared.addUser(user: storeUser)
        WalletManager.shared.updateKeyProvider(provider: provider, storeUser: storeUser)
        try await finishLogin(mnemonic: mnemonic, customToken: customToken)
    }

    func restoreLogin(with userId: String) async throws {
        if Auth.auth().currentUser?.isAnonymous != true {
            try await Auth.auth().signInAnonymously()
            DispatchQueue.main.async {
                self.activatedUID = nil
                self.userInfo = nil
            }
        }

        guard let token = try? await getIDToken(), !token.isEmpty else {
            loginAnonymousIfNeeded()
            throw LLError.restoreLoginFailed
        }
        guard let keyProvider = WalletManager.shared.keyProvider(with: userId) else {
            throw LLError.restoreLoginFailed
        }
        let accountKey = await WalletManager.shared.accountKey(with: userId)

        guard let signData = token.addUserMessage(),
              let signAlgo = accountKey?.signAlgo,
              let hashAlgo = accountKey?.hashAlgo,
              let publicKey = try keyProvider.publicKey(signAlgo: signAlgo)?.hexValue,
              !publicKey.isEmpty
        else {
            throw LLError.signFailed
        }

        let signature = try keyProvider.sign(data: signData, signAlgo: signAlgo, hashAlgo: hashAlgo)

        await IPManager.shared.fetch()
        let key = AccountKey(
            hashAlgo: hashAlgo.index,
            publicKey: publicKey,
            signAlgo: signAlgo.index
        )

        let request = LoginRequest(
            signature: signature.hexValue,
            accountKey: key,
            deviceInfo: IPManager.shared.toParams()
        )
        let response: Network.Response<LoginResponse> = try await Network
            .requestWithRawModel(FRWAPI.User.login(request))
        if response.httpCode == 404 {
            throw LLError.accountNotFound
        }
        guard let customToken = response.data?.customToken, !customToken.isEmpty else {
            throw LLError.restoreLoginFailed
        }
        
        let storeUser = StoreUser(
            publicKey: publicKey,
            address: nil,
            userId: userId,
            keyType: keyProvider.keyType,
            account: accountKey
        )
        WalletManager.shared.updateKeyProvider(provider: keyProvider, storeUser: storeUser)

        try await finishLogin(mnemonic: "", customToken: customToken)
    }

    func restoreLogin(userId: String) async throws {
        EventTrack.Dev.restoreLogin(userId: userId)
        if Auth.auth().currentUser?.isAnonymous != true {
            try await Auth.auth().signInAnonymously()
            DispatchQueue.main.async {
                self.activatedUID = nil
                self.userInfo = nil
            }
        }
        
        guard let token = try? await getIDToken(), !token.isEmpty else {
            loginAnonymousIfNeeded()
            throw LLError.restoreLoginFailed
        }
        let secureKey = try SecureEnclaveKey.wallet(id: userId)

        guard let signData = token.addUserMessage(),
              let publicKey = try secureKey.publicKey()?.hexValue,
              !publicKey.isEmpty
        else {
            throw LLError.signFailed
        }

        let signature = try secureKey.sign(data: signData, hashAlgo: .SHA2_256)

        await IPManager.shared.fetch()
        let key = AccountKey(
            hashAlgo: Flow.HashAlgorithm.SHA2_256.index,
            publicKey: publicKey,
            signAlgo: Flow.SignatureAlgorithm.ECDSA_P256.index
        )

        let request = LoginRequest(
            signature: signature.hexValue,
            accountKey: key,
            deviceInfo: IPManager.shared.toParams()
        )

        let response: Network.Response<LoginResponse> = try await Network
            .requestWithRawModel(FRWAPI.User.login(request))
        if response.httpCode == 404 {
            throw LLError.accountNotFound
        }
        userType = .secure
        guard let customToken = response.data?.customToken, !customToken.isEmpty else {
            throw LLError.restoreLoginFailed
        }
        try await finishLogin(mnemonic: "", customToken: customToken)
    }

    func importLogin(
        by address: String,
        userName: String,
        flowKey: Flow.AccountKey,
        privateKey: any KeyProtocol,
        isImport: Bool = false
    ) async throws {
        if Auth.auth().currentUser?.isAnonymous != true {
            try await Auth.auth().signInAnonymously()
            DispatchQueue.main.async {
                self.activatedUID = nil
                self.userInfo = nil
            }
        }

        guard let token = try? await getIDToken(), !token.isEmpty else {
            loginAnonymousIfNeeded()
            throw LLError.restoreLoginFailed
        }

        guard let signData = token.addUserMessage()
        else {
            throw LLError.signFailed
        }
        let publicKey = flowKey.publicKey.description
        let signature = try privateKey.sign(
            data: signData,
            signAlgo: flowKey.signAlgo,
            hashAlgo: flowKey.hashAlgo
        ).hexValue

        await IPManager.shared.fetch()

        let key = AccountKey(
            hashAlgo: flowKey.hashAlgo.index,
            publicKey: publicKey,
            signAlgo: flowKey.signAlgo.index
        )

        var loginResponse: LoginResponse?
        if isImport {
            let request = RestoreImportRequest(
                username: userName,
                accountKey: key,
                deviceInfo: IPManager.shared.toParams(),
                address: address
            )
            let response: Network.Response<LoginResponse> = try await Network
                .requestWithRawModel(FRWAPI.User.loginWithImport(request))
            if response.httpCode == 404 {
                throw LLError.accountNotFound
            }
            loginResponse = response.data
        } else {
            let request = LoginRequest(
                signature: signature,
                accountKey: key,
                deviceInfo: IPManager.shared.toParams(),
                address: address
            )
            let response: Network.Response<LoginResponse> = try await Network
                .requestWithRawModel(FRWAPI.User.login(request))
            if response.httpCode == 404 {
                throw LLError.accountNotFound
            }
            loginResponse = response.data
        }

        userType = .fromImport
        guard let customToken = loginResponse?.customToken, let uid = loginResponse?.id,
              !customToken.isEmpty
        else {
            throw LLError.restoreLoginFailed
        }
        try privateKey.store(id: privateKey.createKey(uid: uid), password: KeyProvider.password(with: uid))
        log.debug("[user] \(flowKey)")
        let store = StoreUser(
            publicKey: publicKey,
            address: address,
            userId: uid,
            keyType: privateKey.keyType,
            account: flowKey.toStoreKey()
        )
        LocalUserDefaults.shared.addUser(user: store)
        WalletManager.shared.updateKeyProvider(provider: privateKey, storeUser: store)
        log.debug("[user] \(store)")
        try await finishLogin(mnemonic: "", customToken: customToken)

    }
}

// MARK: - Switch Account

extension UserManager {
    func switchAccount(withUID uid: String) async throws {
        if !currentNetwork.isMainnet {
            WalletManager.shared.changeNetwork(.mainnet)
        }

        if uid == activatedUID {
            log.warning("switching the same account")
            return
        }

        if WalletManager.shared.keyProvider(with: uid) != nil {
            try await restoreLogin(with: uid)
            return
        }
        try await restoreLogin(userId: uid)
        // FIXME: data migrate from device to other device,the private key is destructive
//        let allModel = try WallectSecureEnclave.Store.fetchAllModel(by: uid)
//        let model = try WallectSecureEnclave.Store.fetchModel(by: uid)
//
//        if model != nil {
//            try await restoreLogin(userId: uid)
//            return
//        }
//        if model == nil && allModel.count > 0 {
//            WalletManager.shared.warningIfKeyIsInvalid(userId: uid, markHide: true)
//            return
//        }
//
//        throw WalletError.mnemonicMissing
    }
}

// MARK: - Internal Login Logic

extension UserManager {
    private func finishLogin(
        mnemonic: String,
        customToken: String,
        isRegiter: Bool = false
    ) async throws {
        try await firebaseLogin(customToken: customToken)
        var info = try await fetchUserInfo()
        info.type = userType
        let userInfo = info
        fetchMeowDomainStatus(info.username)

        guard let uid = getFirebaseUID() else {
            throw LLError.fetchUserInfoFailed
        }
        if !mnemonic.isEmpty {
            try WalletManager.shared.storeAndActiveMnemonicToKeychain(mnemonic, uid: uid)
        }

        if !loginUIDList.contains(uid), !isRegiter {
            ConfettiManager.show()
        }
        DispatchQueue.main.async {
            self.activatedUID = uid
            self.userInfo = userInfo
            self.insertLoginUID(uid)
            NotificationCenter.default.post(name: .didFinishAccountLogin, object: nil)
            self.uploadUserNameIfNeeded()
        }
    }

    private func insertLoginUID(_ uid: String) {
        if LocalUserDefaults.shared.flowNetwork != .mainnet {
            return
        }
        var oldList = loginUIDList
        oldList.removeAll { $0 == uid }
        oldList.insert(uid, at: 0)
        loginUIDList = oldList
    }

    func deleteLoginUID(_ uid: String) {
        var oldList = loginUIDList
        oldList.removeAll { $0 == uid }
        loginUIDList = oldList
    }

    private func firebaseLogin(customToken: String) async throws {
        let result = try await Auth.auth().signIn(withCustomToken: customToken)
        debugPrint("Logged in -> \(result.user.uid)")
    }

    private func fetchUserInfo() async throws -> UserInfo {
        let response: UserInfoResponse = try await Network.request(FRWAPI.User.userInfo)
        let info = UserInfo(
            avatar: response.avatar,
            nickname: response.nickname,
            username: response.username,
            private: response.private,
            address: nil
        )

        if info.username.isEmpty {
            throw LLError.fetchUserInfoFailed
        }

        return info
    }

    private func fetchMeowDomainStatus(_ username: String) {
        Task {
            do {
                _ = try await FlowNetwork.queryAddressByDomainFlowns(
                    domain: username,
                    root: Contact.DomainType.meow.domain
                )
                if userInfo?.username == username {
                    DispatchQueue.main.async {
                        self.isMeowDomainEnabled = true
                    }
                }
            } catch {
                if userInfo?.username == username {
                    DispatchQueue.main.async {
                        self.isMeowDomainEnabled = false
                    }
                }
            }
        }
    }
}

// MARK: - Internal

extension UserManager {
    private func loginAnonymousIfNeeded() {
        if Auth.auth().currentUser == nil {
            Task {
                do {
                    try await Auth.auth().signInAnonymously()
                } catch {
                    log.error("signInAnonymously failed", context: error)
                }
            }
        }
    }

    private func getFirebaseUID() -> String? {
        Auth.auth().currentUser?.uid
    }

    func getIDToken() async throws -> String? {
        try await Auth.auth().currentUser?.getIDToken()
    }
}

// MARK: - Modify

extension UserManager {
    private func uploadUserNameIfNeeded() {
        if !isLoggedIn {
            return
        }

        let username = userInfo?.username ?? ""
        let displayName = Auth.auth().currentUser?.displayName ?? ""

        if !username.isEmpty, username != displayName {
            Task {
                await uploadUserName(username: username)
            }
        }
    }

    private func uploadUserName(username: String) async {
        guard let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() else {
            return
        }

        changeRequest.displayName = username
        do {
            try await changeRequest.commitChanges()
        } catch {
            debugPrint("update displayName failed")
        }
    }

    func updateNickname(_ name: String) {
        guard let current = userInfo else {
            return
        }

        let newUserInfo = UserInfo(
            avatar: current.avatar,
            nickname: name,
            username: current.username,
            private: current.private,
            address: nil
        )
        userInfo = newUserInfo
    }

    func updatePrivate(_ isPrivate: Bool) {
        guard let current = userInfo else {
            return
        }

        let newUserInfo = UserInfo(
            avatar: current.avatar,
            nickname: current.nickname,
            username: current.username,
            private: isPrivate ? 2 : 1,
            address: nil
        )
        userInfo = newUserInfo
    }

    func updateAvatar(_ avatar: String) {
        guard let current = userInfo else {
            return
        }

        let newUserInfo = UserInfo(
            avatar: avatar,
            nickname: current.nickname,
            username: current.username,
            private: current.private,
            address: nil
        )
        userInfo = newUserInfo
    }
}

// used by API FRWAPI.Utils.flowAddress
extension UserManager {
    struct AccountResponse: Codable {
        let publicKey: String?
        var accounts: [AccountInfo]?
    }

    struct AccountInfo: Codable {
        let address: String?
        let weight: Int?
        let keyId: Int?
    }
}

// MARK: UserManager.StoreUser

extension UserManager {

    struct Accountkey: Codable {
        public var index: Int
        public let signAlgo: Flow.SignatureAlgorithm
        public let hashAlgo: Flow.HashAlgorithm
        public let weight: Int
    }

    struct StoreUser: Codable {
        let publicKey: String
        let address: String?
        let userId: String
        let keyType: FlowWalletKit.KeyType
        let account: UserManager.Accountkey?
        var updateAt: TimeInterval = ceil(Date().timeIntervalSince1970)

        func copy(address: String? = nil, account: UserManager.Accountkey? = nil) -> StoreUser {
            return StoreUser(publicKey: publicKey,
                             address: address ?? self.address,
                             userId: userId,
                             keyType: keyType,
                             account: account ?? self.account)
        }
    }
}
extension Flow.AccountKey {
    func toStoreKey() -> UserManager.Accountkey {
        UserManager.Accountkey(index: index, signAlgo: signAlgo, hashAlgo: hashAlgo, weight: weight)
    }
}

