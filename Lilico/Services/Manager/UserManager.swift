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

    @Published var userInfo: UserInfo?
    @Published var isLoggedIn: Bool = false
    @Published var isAnonymous: Bool = true
    @Published var isMeowDomainEnabled: Bool = false
    
    private var cancelSets = Set<AnyCancellable>()
    private var initUserInfoUpdated = false

    init() {
        checkIfHasOldAccount()
        
        MultiAccountStorage.shared.$userInfo
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink { newUserInfo in
                self.userInfo = newUserInfo
                self.refreshFlags()
                self.uploadUserNameIfNeeded()
                
                if !self.initUserInfoUpdated {
                    self.initUserInfoUpdated = true
                    Task {
                        try? await self.fetchUserInfo()
                    }
                }
            }.store(in: &cancelSets)
        
        loginAnonymousIfNeeded()
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
            MultiAccountStorage.shared.reset()
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
        
        guard let uid = getUid(), let mnemonic = WalletManager.shared.getMnemonicFromKeychain(uid: uid) else {
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

// MARK: - Internal Login Logic

extension UserManager {
    private func finishLogin(mnemonic: String, customToken: String) async throws {
        try await firebaseLogin(customToken: customToken)
        try await fetchUserInfo()
        uploadUserNameIfNeeded()

        guard let uid = UserManager.shared.getUid() else {
            throw LLError.fetchUserInfoFailed
        }

        try WalletManager.shared.storeAndActiveMnemonicToKeychain(mnemonic, uid: uid)
    }

    private func firebaseLogin(customToken: String) async throws {
        let result = try await Auth.auth().signIn(withCustomToken: customToken)
        debugPrint("Logged in -> \(result.user.uid)")
    }

    private func fetchUserInfo() async throws {
        if !isLoggedIn {
            return
        }
        
        let response: UserInfoResponse = try await Network.request(LilicoAPI.User.userInfo)
        let info = UserInfo(avatar: response.avatar, nickname: response.nickname, username: response.username, private: response.private, address: nil)

        if info.username.isEmpty {
            throw LLError.fetchUserInfoFailed
        }

        DispatchQueue.main.async {
            MultiAccountStorage.shared.applyUserInfo(info)
            
            DispatchQueue.main.async {
                self.fetchMeowDomainStatus()
            }
        }
    }
    
    private func fetchMeowDomainStatus() {
        guard let username = self.userInfo?.username else {
            return
        }
        
        Task {
            do {
                let _ = try await FlowNetwork.queryAddressByDomainFlowns(domain: username, root: Contact.DomainType.meow.domain)
                DispatchQueue.main.async {
                    self.isMeowDomainEnabled = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.isMeowDomainEnabled = false
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

    func getUid() -> String? {
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
        MultiAccountStorage.shared.applyUserInfo(newUserInfo)
    }

    func updatePrivate(_ isPrivate: Bool) {
        guard let current = userInfo else {
            return
        }

        let newUserInfo = UserInfo(avatar: current.avatar, nickname: current.nickname, username: current.username, private: isPrivate ? 2 : 1, address: nil)
        MultiAccountStorage.shared.applyUserInfo(newUserInfo)
    }

    func updateAvatar(_ avatar: String) {
        guard let current = userInfo else {
            return
        }

        let newUserInfo = UserInfo(avatar: avatar, nickname: current.nickname, username: current.username, private: current.private, address: nil)
        MultiAccountStorage.shared.applyUserInfo(newUserInfo)
    }
}
