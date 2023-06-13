//
//  MultiAccountStorage.swift
//  Lilico
//
//  Created by Selina on 8/6/2023.
//

import Foundation
import Combine
import Firebase
import FirebaseAuth

class MultiAccountStorage: ObservableObject {
    static let shared = MultiAccountStorage()
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(willReset), name: .willResetWallet, object: nil)
    }
    
    func upgradeFromOldVersionIfNeeded() {
        if LocalUserDefaults.shared.multiAccountUpgradeFlag {
            return
        }
        
        guard let user = Auth.auth().currentUser, !user.isAnonymous, !user.uid.isEmpty else {
            LocalUserDefaults.shared.multiAccountUpgradeFlag = true
            return
        }
        
        let uid = user.uid
                
        AppFolderType.userStorage(uid).createFolderIfNeeded()
        
        if let legacyUserInfo = LocalUserDefaults.shared.legacyUserInfo {
            do {
                try saveUserInfo(legacyUserInfo, uid: uid)
            } catch {
                log.error("save legacy user info failed", context: error)
            }
            
            LocalUserDefaults.shared.legacyUserInfo = nil
        }
        
        LocalUserDefaults.shared.activatedUID = uid
        LocalUserDefaults.shared.loginUIDList = [uid]
        
        LocalUserDefaults.shared.multiAccountUpgradeFlag = true
    }
}

// MARK: -
extension MultiAccountStorage {
    @objc private func willReset() {
        guard let uid = UserManager.shared.activatedUID else { return }
        delete(uid: uid)
    }
    
    private func delete(uid: String) {
        do {
            try AppFolderType.userStorage(uid).remove()
        } catch {
            log.error("delete user storage failed", context: error)
        }
    }
}

// MARK: - Saver
extension MultiAccountStorage {
    func saveUserInfo(_ newUserInfo: UserInfo?, uid: String) throws {
        AppFolderType.userStorage(uid).createFolderIfNeeded()
        
        if let newUserInfo = newUserInfo {
            let data = try JSONEncoder().encode(newUserInfo)
            try data.write(to: UserStorageFileType.userInfo(uid).url)
        } else {
            // remove file
            try UserStorageFileType.userInfo(uid).remove()
        }
    }
    
    func saveWalletInfo(_ walletInfo: UserWalletResponse?, uid: String) throws {
        AppFolderType.userStorage(uid).createFolderIfNeeded()
        
        if let walletInfo = walletInfo {
            let data = try JSONEncoder().encode(walletInfo)
            try data.write(to: UserStorageFileType.walletInfo(uid).url)
        } else {
            // remove file
            try UserStorageFileType.walletInfo(uid).remove()
        }
    }
}

// MARK: - Getter
extension MultiAccountStorage {
    func getUserInfo(_ uid: String) -> UserInfo? {
        if !UserStorageFileType.userInfo(uid).isExist {
            log.warning("user info cache is not exist")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: UserStorageFileType.userInfo(uid).url)
            let userInfo = try JSONDecoder().decode(UserInfo.self, from: data)
            return userInfo
        } catch {
            log.error("get user info failed", context: error)
            return nil
        }
    }
    
    func getWalletInfo(_ uid: String) -> UserWalletResponse? {
        if !UserStorageFileType.walletInfo(uid).isExist {
            log.warning("wallet info cache is not exist")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: UserStorageFileType.walletInfo(uid).url)
            let walletInfo = try JSONDecoder().decode(UserWalletResponse.self, from: data)
            return walletInfo
        } catch {
            log.error("get wallet info failed", context: error)
            return nil
        }
    }
}
