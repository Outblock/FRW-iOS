//
//  UserManager.swift
//  Lilico
//
//  Created by Hao Fu on 30/12/21.
//

import Firebase
import FirebaseAuth
import Foundation
import Combine

class UserManager: ObservableObject {
    static let shared = UserManager()

    @Published var activatedUID: String? = LocalUserDefaults.shared.activatedUID {
        didSet {
            LocalUserDefaults.shared.activatedUID = activatedUID
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
    @Published var isLoggedIn: Bool = false
    @Published var isAnonymous: Bool = true
    @Published var isMeowDomainEnabled: Bool = false

    init() {
        checkIfHasOldAccount()
        
        if let activatedUID = activatedUID {
            self.userInfo = MultiAccountStorage.shared.getUserInfo(activatedUID)
            self.refreshFlags()
            self.uploadUserNameIfNeeded()
            self.initRefreshUserInfo()
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
                let info = try await self.fetchUserInfo()
                
                if activatedUID != uid { return }
                
                DispatchQueue.main.async {
                    self.userInfo = info
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
        
        if !hasOldAccount() {
            LocalUserDefaults.shared.tryToRestoreAccountFlag = true
            return
        }
    }
}

// MARK: - Reset

extension UserManager {
    func reset() {
        log.info("reset start")
        
        NotificationCenter.default.post(name: .willResetWallet)
        
        do {
            try Auth.auth().signOut()
            loginAnonymousIfNeeded()
            
            NotificationCenter.default.post(name: .didResetWallet)
            
            Router.popToRoot()
            
            log.debug("reset finished")
        } catch {
            log.error("reset failed", context: error)
        }
    }
}

// MARK: - Register

extension UserManager {
    func register(_ username: String, mnemonic: String? = nil) async throws {
        guard let hdWallet = WalletManager.shared.createHDWallet(mnemonic: mnemonic) else {
            HUD.error(title: "empty_wallet_key".localized)
            throw LLError.emptyWallet
        }
        
        if Auth.auth().currentUser != nil {
            try await Auth.auth().signInAnonymously()
            DispatchQueue.main.async {
                self.userInfo = nil
                self.activatedUID = nil
            }
        }

        let key = hdWallet.flowAccountKey
        let request = RegisterRequest(username: username, accountKey: key.toCodableModel())
        let model: RegisterResponse = try await Network.request(LilicoAPI.User.register(request))

        try await finishLogin(mnemonic: hdWallet.mnemonic, customToken: model.customToken)
        WalletManager.shared.asyncCreateWalletAddressFromServer()
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
        LocalUserDefaults.shared.tryToRestoreAccountFlag = true
        
        HUD.loading()
        
        guard let uid = getFirebaseUID(), let mnemonic = WalletManager.shared.getMnemonicFromKeychain(uid: uid) else {
            HUD.dismissLoading()
            HUD.error(title: "restore_account_failed".localized)
            return
        }
        
        Task {
            do {
                try await UserManager.shared.restoreLogin(withMnemonic: mnemonic)
                HUD.dismissLoading()
                HUD.success(title: "login_success".localized)
            } catch {
                HUD.dismissLoading()
                
                HUD.showAlert(title: "", msg: "restore_account_failed".localized, cancelAction: {
                    
                }, confirmTitle: "retry".localized) {
                    self.tryToRestoreOldAccountOnFirstLaunch()
                }
            }
        }
    }
    
    func restoreLogin(withMnemonic mnemonic: String) async throws {
        guard let hdWallet = WalletManager.shared.createHDWallet(mnemonic: mnemonic) else {
            throw LLError.incorrectPhrase
        }
        
        if Auth.auth().currentUser != nil {
            try await Auth.auth().signInAnonymously()
            DispatchQueue.main.async {
                self.userInfo = nil
                self.activatedUID = nil
            }
        }

        guard let token = try? await getIDToken(), !token.isEmpty else {
            loginAnonymousIfNeeded()
            throw LLError.restoreLoginFailed
        }

        let publicKey = hdWallet.getPublicKey()
        guard let signature = hdWallet.sign(token) else {
            throw LLError.restoreLoginFailed
        }

        let request = LoginRequest(publicKey: publicKey, signature: signature)
        let response: Network.Response<LoginResponse> = try await Network.requestWithRawModel(LilicoAPI.User.login(request))
        if response.httpCode == 404 {
            throw LLError.accountNotFound
        }

        guard let customToken = response.data?.customToken, !customToken.isEmpty else {
            throw LLError.restoreLoginFailed
        }

        try await finishLogin(mnemonic: hdWallet.mnemonic, customToken: customToken)
    }
}

// MARK: - Switch Account

extension UserManager {
    func switchAccount(withUID uid: String) async throws {
        guard let mnemonic = WalletManager.shared.getMnemonicFromKeychain(uid: uid) else {
            return
        }
        
        try await restoreLogin(withMnemonic: mnemonic)
    }
}

// MARK: - Internal Login Logic

extension UserManager {
    private func finishLogin(mnemonic: String, customToken: String) async throws {
        try await firebaseLogin(customToken: customToken)
        let info = try await fetchUserInfo()
        fetchMeowDomainStatus(info.username)
        uploadUserNameIfNeeded()

        guard let uid = getFirebaseUID() else {
            throw LLError.fetchUserInfoFailed
        }

        try WalletManager.shared.storeAndActiveMnemonicToKeychain(mnemonic, uid: uid)
        
        DispatchQueue.main.async {
            self.activatedUID = uid
            self.userInfo = info
            NotificationCenter.default.post(name: .didFinishAccountLogin, object: nil)
        }
    }

    private func firebaseLogin(customToken: String) async throws {
        let result = try await Auth.auth().signIn(withCustomToken: customToken)
        debugPrint("Logged in -> \(result.user.uid)")
    }

    private func fetchUserInfo() async throws -> UserInfo {
        let response: UserInfoResponse = try await Network.request(LilicoAPI.User.userInfo)
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
    private func refreshFlags() {
        let newIsLoggedIn = userInfo != nil
        if isLoggedIn != newIsLoggedIn {
            isLoggedIn = newIsLoggedIn
        }
        
        isAnonymous = Auth.auth().currentUser?.isAnonymous ?? true
    }

    private func loginAnonymousIfNeeded() {
        if isLoggedIn {
            return
        }

        if Auth.auth().currentUser == nil {
            Task {
                do {
                    try await Auth.auth().signInAnonymously()
                    DispatchQueue.main.async {
                        self.refreshFlags()
                    }
                } catch {
                    debugPrint("signInAnonymously failed: \(error.localizedDescription)")
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
        if isAnonymous || !isLoggedIn {
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
        self.userInfo = newUserInfo
    }

    func updatePrivate(_ isPrivate: Bool) {
        guard let current = userInfo else {
            return
        }

        let newUserInfo = UserInfo(avatar: current.avatar, nickname: current.nickname, username: current.username, private: isPrivate ? 2 : 1, address: nil)
        self.userInfo = newUserInfo
    }

    func updateAvatar(_ avatar: String) {
        guard let current = userInfo else {
            return
        }

        let newUserInfo = UserInfo(avatar: avatar, nickname: current.nickname, username: current.username, private: current.private, address: nil)
        self.userInfo = newUserInfo
    }
}
