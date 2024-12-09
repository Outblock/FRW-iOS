//
//  MultiAccountStorage.swift
//  Flow Wallet
//
//  Created by Selina on 8/6/2023.
//

import Combine
import Firebase
import FirebaseAuth
import Foundation

// MARK: - MultiAccountStorage.UserDefaults

extension MultiAccountStorage {
    struct UserDefaults: Codable {
        var backupType: BackupManager.BackupType = .none
    }
}

// MARK: - MultiAccountStorage

class MultiAccountStorage: ObservableObject {
    // MARK: Lifecycle

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willReset),
            name: .willResetWallet,
            object: nil
        )
    }

    // MARK: Internal

    static let shared = MultiAccountStorage()

    func upgradeFromOldVersionIfNeeded() {
        if LocalUserDefaults.shared.multiAccountUpgradeFlag {
            return
        }

        guard let user = Auth.auth().currentUser, !user.isAnonymous, !user.uid.isEmpty else {
            LocalUserDefaults.shared.multiAccountUpgradeFlag = true
            return
        }

        guard let legacyUserInfo = LocalUserDefaults.shared.legacyUserInfo else {
            // firebase is login but userInfo is nil, Maybe it is a new app installed
            // UserManager 'restore from keychain' logic will handle this
            LocalUserDefaults.shared.multiAccountUpgradeFlag = true
            return
        }

        let uid = user.uid

        AppFolderType.userStorage(uid).createFolderIfNeeded()

        do {
            try saveUserInfo(legacyUserInfo, uid: uid)
        } catch {
            log.error("save legacy user info failed", context: error)
        }

        LocalUserDefaults.shared.legacyUserInfo = nil

        LocalUserDefaults.shared.activatedUID = uid
        LocalUserDefaults.shared.loginUIDList = [uid]
        setBackupType(LocalUserDefaults.shared.legacyBackupType, uid: uid, postNotification: false)

        LocalUserDefaults.shared.multiAccountUpgradeFlag = true
    }
}

// MARK: -

extension MultiAccountStorage {
    @objc
    private func willReset() {
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
        UserStorageFileType.userInfo(uid).createFolderIfNeeded()

        if let newUserInfo = newUserInfo {
            let data = try JSONEncoder().encode(newUserInfo)
            try data.write(to: UserStorageFileType.userInfo(uid).url)
        } else {
            // remove file
            try UserStorageFileType.userInfo(uid).remove()
        }
    }

    func saveWalletInfo(_ walletInfo: UserWalletResponse?, uid: String) throws {
        UserStorageFileType.walletInfo(uid).createFolderIfNeeded()

        if let walletInfo = walletInfo {
            let data = try JSONEncoder().encode(walletInfo)
            try data.write(to: UserStorageFileType.walletInfo(uid).url)
        } else {
            // remove file
            try UserStorageFileType.walletInfo(uid).remove()
        }
    }

    func saveUserDefaults(_ userDefaults: MultiAccountStorage.UserDefaults?, uid: String) throws {
        UserStorageFileType.userDefaults(uid).createFolderIfNeeded()

        if let userDefaults = userDefaults {
            let data = try JSONEncoder().encode(userDefaults)
            try data.write(to: UserStorageFileType.userDefaults(uid).url)
        } else {
            // remove file
            try UserStorageFileType.userDefaults(uid).remove()
        }
    }

    func saveChildAccounts(_ childAccounds: [ChildAccount]?, uid: String, address: String) throws {
        UserStorageFileType.childAccounts(uid, address).createFolderIfNeeded()

        if let childAccounds = childAccounds {
            let data = try JSONEncoder().encode(childAccounds)
            try data.write(to: UserStorageFileType.childAccounts(uid, address).url)
        } else {
            try UserStorageFileType.childAccounts(uid, address).remove()
        }
    }
}

// MARK: - Getter

extension MultiAccountStorage {
    func getUserInfo(_ uid: String) -> UserInfo? {
        if !UserStorageFileType.userInfo(uid).isExist {
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

    func getUserDefaults(_ uid: String) -> MultiAccountStorage.UserDefaults? {
        if !UserStorageFileType.userDefaults(uid).isExist {
            return nil
        }

        do {
            let data = try Data(contentsOf: UserStorageFileType.userDefaults(uid).url)
            let ud = try JSONDecoder().decode(MultiAccountStorage.UserDefaults.self, from: data)
            return ud
        } catch {
            log.error("get user defaults failed", context: error)
            return nil
        }
    }

    func getChildAccounts(uid: String, address: String) -> [ChildAccount]? {
        if !UserStorageFileType.childAccounts(uid, address).isExist {
            log.warning("child accounts cache is not exist")
            return nil
        }

        do {
            let data = try Data(contentsOf: UserStorageFileType.childAccounts(uid, address).url)
            let list = try JSONDecoder().decode([ChildAccount].self, from: data)
            return list
        } catch {
            log.error("get child accounts failed", context: error)
            return nil
        }
    }
}

// MARK: - UserDefaults

extension MultiAccountStorage {
    func getBackupType(_ uid: String) -> BackupManager.BackupType {
        getUserDefaults(uid)?.backupType ?? .none
    }

    func setBackupType(
        _ type: BackupManager.BackupType,
        uid: String,
        postNotification: Bool = true
    ) {
        var ud = getUserDefaults(uid) ?? MultiAccountStorage.UserDefaults()
        ud.backupType = type

        do {
            try saveUserDefaults(ud, uid: uid)
            if postNotification {
                NotificationCenter.default.post(name: .backupTypeDidChanged)
            }
        } catch {
            log.error("save user defaults failed", context: error)
        }
    }
}
