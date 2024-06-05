//
//  UserManager.swift
//  Flow Wallet
//
//  Created by Hao Fu on 30/12/21.
//

import Combine
import Firebase
import FirebaseAuth
import Flow
import FlowWalletCore
import Foundation
import Alamofire

extension UserManager {
    enum UserType: Codable {
        case phrase
        case secure
    }
}

class UserManager: ObservableObject {
    static let shared = UserManager()

    @Published var activatedUID: String? = LocalUserDefaults.shared.activatedUID {
        didSet {
            LocalUserDefaults.shared.activatedUID = activatedUID
            if oldValue != activatedUID {
                clearWhenUserChanged()
            }
        }
    }
    
    @Published var userInfo: UserInfo? {
        didSet {
            do {
                guard let uid = activatedUID else { return }
                try MultiAccountStorage.shared.saveUserInfo(userInfo, uid: uid)
            } catch {
                log.error("save user info failed", context: error)
            }
        }
    }
    
    @Published var loginUIDList: [String] = [] {
        didSet {
            LocalUserDefaults.shared.loginUIDList = loginUIDList
        }
    }
    
    @Published var isMeowDomainEnabled: Bool = false
    
    var userType: UserManager.UserType = .secure
    
    var isLoggedIn: Bool {
        return activatedUID != nil
    }

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
    
    func verifyUserType(by userId: String) {
        Task {
            do {
                userType = try await checkUserType()
            }
            catch {
                log.error("[User] check user type:\(error)")
            }
        }
    }
    
    private func checkUserType() async throws -> UserManager.UserType {
        guard let address = WalletManager.shared.getPrimaryWalletAddress(), let uid = activatedUID else { return .secure }
        
        let account = try await FlowNetwork.getAccountAtLatestBlock(address: address)
        
        if let mnemonic = WalletManager.shared.getMnemonicFromKeychain(uid: uid), !mnemonic.isEmpty {
            let hdWallet = WalletManager.shared.createHDWallet(mnemonic: mnemonic)
            let accountKeys = account.keys.first { $0.publicKey.description == hdWallet?.getPublicKey() }
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
    func register(_ username: String, mnemonic: String? = nil) async throws -> String? {
        if Auth.auth().currentUser?.isAnonymous != true {
            try await Auth.auth().signInAnonymously()
            DispatchQueue.main.async {
                self.activatedUID = nil
                self.userInfo = nil
            }
        }
        
        let sec = try WallectSecureEnclave()
        let key = try sec.accountKey()
        
        if IPManager.shared.info == nil {
            await IPManager.shared.fetch()
        }
        let request = RegisterRequest(username: username, accountKey: key.toCodableModel(), deviceInfo: IPManager.shared.toParams())
        let model: RegisterResponse = try await Network.request(FRWAPI.User.register(request))

        try await finishLogin(mnemonic: "", customToken: model.customToken)
        WalletManager.shared.asyncCreateWalletAddressFromServer()
        userType = .secure
        if let privateKey = sec.key.privateKey {
            try WallectSecureEnclave.Store.store(key: model.id, value: privateKey.dataRepresentation)
        } else {
            log.error("store public key on iPhone failed")
        }
        
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
                let list = try WallectSecureEnclave.Store.fetch()
                var addressList: [String: String] = [:]
                for item in list {
                    do {
                        let sec = try WallectSecureEnclave(privateKey: item.publicKey)
                        guard let publicKey = sec.key.publickeyValue else { continue }
                        let response: AccountResponse = try await Network.requestWithRawModel(FRWAPI.Utils.flowAddress(publicKey))
                        let account = response.accounts?.filter { ($0.weight ?? 0) >= 1000 && $0.address != nil }.first
                        if let model = account {
                            addressList[item.uniq] = model.address ?? "0x"
                        }
                    } catch {
                        log.error("[Launch] first login check failed:\(item.uniq):\(error)")
                    }
                }
                let uidList = addressList.map{ $0.key }
                let userAddress = addressList
                DispatchQueue.main.async {
                    self.loginUIDList = uidList
                    LocalUserDefaults.shared.userAddressOfDeletedApp = userAddress
                    LocalUserDefaults.shared.tryToRestoreAccountFlag = true
                }
                
                HUD.dismissLoading()
                
            } catch {
                HUD.dismissLoading()
                HUD.showAlert(title: "", msg: "restore_account_failed".localized, cancelAction: {}, confirmTitle: "retry".localized) {
                    self.tryToRestoreOldAccountOnFirstLaunch()
                }
            }
        }
    }
    
    func restoreLogin(withMnemonic mnemonic: String, userId: String? = nil) async throws {
        if let uid = userId {
            if let address = MultiAccountStorage.shared.getWalletInfo(uid)?.currentNetworkWalletModel?.getAddress {
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
        var publicKey = ""
        var signature = ""
        var mnemonicStr = ""
        if let hdWallet = WalletManager.shared.createHDWallet(mnemonic: mnemonic) {
            publicKey = hdWallet.getPublicKey()
            guard let signToken = hdWallet.sign(token) else {
                throw LLError.restoreLoginFailed
            }
            signature = signToken
            mnemonicStr = hdWallet.mnemonic
        }
        
        userType = .phrase
        await IPManager.shared.fetch()
        let hashAlgo = Flow.HashAlgorithm.SHA2_256.index
        let signAlgo = Flow.SignatureAlgorithm.ECDSA_SECP256k1.index
        let key = AccountKey(hashAlgo: hashAlgo,
                             publicKey: publicKey,
                             signAlgo: signAlgo)
        
        let request = LoginRequest(signature: signature, accountKey: key, deviceInfo: IPManager.shared.toParams())
        let response: Network.Response<LoginResponse> = try await Network.requestWithRawModel(FRWAPI.User.login(request))
        if response.httpCode == 404 {
            throw LLError.accountNotFound
        }

        guard let customToken = response.data?.customToken, !customToken.isEmpty else {
            throw LLError.restoreLoginFailed
        }

        try await finishLogin(mnemonic: mnemonicStr, customToken: customToken)
    }
    
    func restoreLogin(userId: String) async throws {
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
        
        guard let publicData = try WallectSecureEnclave.Store.fetch(by: userId), !publicData.isEmpty else {
            throw LLError.restoreLoginFailed
        }
        
        let sec = try WallectSecureEnclave(privateKey: publicData)
    
        guard let signData = token.AddUserMessage(),
              let publicKey = sec.key.publickeyValue,
              !publicKey.isEmpty
        else {
            throw LLError.signFailed
        }
        let signature = try sec.sign(data: signData).hexValue
        await IPManager.shared.fetch()
        // TODO: hash & sign algo
        let key = AccountKey(hashAlgo: Flow.HashAlgorithm.SHA2_256.index,
                             publicKey: publicKey,
                             signAlgo: Flow.SignatureAlgorithm.ECDSA_P256.index)
        
        let request = LoginRequest(signature: signature, accountKey: key, deviceInfo: IPManager.shared.toParams())
        let response: Network.Response<LoginResponse> = try await Network.requestWithRawModel(FRWAPI.User.login(request))
        if response.httpCode == 404 {
            throw LLError.accountNotFound
        }
        userType = .secure
        guard let customToken = response.data?.customToken, !customToken.isEmpty else {
            throw LLError.restoreLoginFailed
        }
        
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
        
        if let mnemonic = WalletManager.shared.getMnemonicFromKeychain(uid: uid), !mnemonic.isEmpty {
            var addressStr = LocalUserDefaults.shared.userAddressOfDeletedApp[uid]
            if addressStr == nil {
                addressStr = MultiAccountStorage.shared.getWalletInfo(uid)?.getNetworkWalletModel(network: .mainnet)?.getAddress
            }
            guard let address = addressStr else {
                throw LLError.invalidAddress
            }
            var accountKeys: Flow.AccountKey?
            let account = try? await FlowNetwork.getAccountAtLatestBlock(address: address)
            let hdWallet = WalletManager.shared.createHDWallet(mnemonic: mnemonic)
            accountKeys = account?.keys.first { $0.publicKey.description == hdWallet?.getPublicKey() }
            if accountKeys != nil {
                try await restoreLogin(withMnemonic: mnemonic, userId: uid)
                return
            }
        }
        
        if try (WallectSecureEnclave.Store.fetch(by: uid)) != nil {
            try await restoreLogin(userId: uid)
            return
        }
        
        throw WalletError.mnemonicMissing
    }
}

// MARK: - Internal Login Logic

extension UserManager {
    private func finishLogin(mnemonic: String, customToken: String) async throws {
        try await firebaseLogin(customToken: customToken)
        var info = try await fetchUserInfo()
        info.type = self.userType
        let userInfo = info
        fetchMeowDomainStatus(info.username)

        guard let uid = getFirebaseUID() else {
            throw LLError.fetchUserInfoFailed
        }
        if !mnemonic.isEmpty {
            try WalletManager.shared.storeAndActiveMnemonicToKeychain(mnemonic, uid: uid)
        }
        
        if !loginUIDList.contains(uid) {
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
    
    private func deleteLoginUID(_ uid: String) {
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
        let info = UserInfo(avatar: response.avatar, nickname: response.nickname, username: response.username, private: response.private, address: nil)

        if info.username.isEmpty {
            throw LLError.fetchUserInfoFailed
        }
        
        return info
    }
    
    private func fetchMeowDomainStatus(_ username: String) {
        Task {
            do {
                let _ = try await FlowNetwork.queryAddressByDomainFlowns(domain: username, root: Contact.DomainType.meow.domain)
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
        return Auth.auth().currentUser?.uid
    }

    func getIDToken() async throws -> String? {
        return try await Auth.auth().currentUser?.getIDToken()
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

        let newUserInfo = UserInfo(avatar: current.avatar, nickname: name, username: current.username, private: current.private, address: nil)
        userInfo = newUserInfo
    }

    func updatePrivate(_ isPrivate: Bool) {
        guard let current = userInfo else {
            return
        }

        let newUserInfo = UserInfo(avatar: current.avatar, nickname: current.nickname, username: current.username, private: isPrivate ? 2 : 1, address: nil)
        userInfo = newUserInfo
    }

    func updateAvatar(_ avatar: String) {
        guard let current = userInfo else {
            return
        }

        let newUserInfo = UserInfo(avatar: avatar, nickname: current.nickname, username: current.username, private: current.private, address: nil)
        userInfo = newUserInfo
    }
}

// used by API FRWAPI.Utils.flowAddress
extension UserManager {
    struct AccountResponse: Codable {
        let publicKey: String?
        let accounts: [AccountInfo]?
    }
    
    struct AccountInfo: Codable {
        let address: String?
        let weight: Int?
        let keyId: Int?
    }
}
