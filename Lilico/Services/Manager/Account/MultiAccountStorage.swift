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
    private init() {}
    
    @Published private(set) var activatedUID: String?
    @Published private(set) var userInfo: UserInfo?
    
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
                try saveUserInfo(legacyUserInfo)
            } catch {
                log.error("save legacy user info failed", context: error)
            }
            
            LocalUserDefaults.shared.legacyUserInfo = nil
        }
        
        LocalUserDefaults.shared.activatedUID = uid
        
        LocalUserDefaults.shared.multiAccountUpgradeFlag = true
    }
    
    func setup() {
        activatedUID = LocalUserDefaults.shared.activatedUID
        
        if let uid = activatedUID {
            userInfo = getUserInfo(uid)
        }
    }
}

// MARK: -
extension MultiAccountStorage {
    /// reset current activate account
    func reset() {
        applyUserInfo(nil)
        applyActivatedUID(nil)
    }
}

// MARK: - Setter
extension MultiAccountStorage {
    
    /// apply user info and save to file
    func applyUserInfo(_ newUserInfo: UserInfo?) {
        guard let uid = activatedUID else {
            log.warning("activatedUID is nil")
            return
        }

        do {
            try saveUserInfo(newUserInfo)
            
            if let newUserInfo = newUserInfo {
                let data = try JSONEncoder().encode(newUserInfo)
                try data.write(to: UserStorageFileType.userInfo(uid).url)
                userInfo = newUserInfo
            } else {
                // remove file
                try UserStorageFileType.userInfo(uid).remove()
                userInfo = nil
            }
        } catch {
            log.error("apply user info failed", context: error)
        }
    }
    
    func applyActivatedUID(_ uid: String?) {
        // TODO: - Maybe it's more appropriate to put it on UI action.
        if let activatedUID = activatedUID, let uid = uid, activatedUID != uid {
            NotificationCenter.default.post(name: .willSwitchAccount, object: nil)
        }
        
        activatedUID = uid
        LocalUserDefaults.shared.activatedUID = uid
    }
}

// MARK: - Saver
extension MultiAccountStorage {
    
    /// only save to file
    private func saveUserInfo(_ newUserInfo: UserInfo?) throws {
        guard let uid = activatedUID else {
            log.warning("activatedUID is nil")
            return
        }

        if let newUserInfo = newUserInfo {
            let data = try JSONEncoder().encode(newUserInfo)
            try data.write(to: UserStorageFileType.userInfo(uid).url)
        } else {
            // remove file
            try UserStorageFileType.userInfo(uid).remove()
        }
    }
}

// MARK: - Getter
extension MultiAccountStorage {
    private func getUserInfo(_ uid: String) -> UserInfo? {
        if !UserStorageFileType.userInfo(uid).isExist {
            log.warning("activatedUID is nil")
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
}
