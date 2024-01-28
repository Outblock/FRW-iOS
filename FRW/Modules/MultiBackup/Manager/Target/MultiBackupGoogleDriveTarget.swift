//
//  MultiBackupGoogleDriveTarget.swift
//  FRW
//
//  Created by cat on 2024/1/6.
//

import GoogleAPIClientForREST_Drive
import GoogleAPIClientForRESTCore
import GoogleSignIn
import GTMSessionFetcherCore
import SwiftUI
import UIKit

class MultiBackupGoogleDriveTarget: MultiBackupTarget {
    var uploadedItem: MultiBackupManager.StoreItem?
    
    var registeredDeviceInfo: SyncInfo.DeviceInfo?
    
    private var clientID = ""
    private lazy var config: GIDConfiguration = .init(clientID: clientID)

    private var api: GoogleDriveAPI?
    
    init() {
        guard let filePath = Bundle.main.path(forResource: "GoogleOAuth2", ofType: "plist") else {
            fatalError("fatalError ===> Can't find GoogleOAuth2.plist")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        if let clientID = plist?.object(forKey: "CLIENT_ID") as? String {
            self.clientID = clientID
        }
    }
    
    var isPrepared: Bool {
        return api != nil
    }
    
    func loginCloud() async throws {
        if !GIDSignIn.sharedInstance.hasPreviousSignIn() {
            return
        }
        let user = try await googleRestoreLogin()
        
        if !checkUserScopes(user: user) {
            return
        }
        createGoogleDriveService(user: user)
    }
}

extension MultiBackupGoogleDriveTarget {
    func upload(password: String) async throws {
        try await prepare()
        
        let list = try await getCurrentDriveItems()
        let newList = try await MultiBackupManager.shared.addNewMnemonic(on: .google, list: list, password: password)
        let encrypedString = try MultiBackupManager.shared.encryptList(newList)
        guard let data = encrypedString.data(using: .utf8), !data.isEmpty else {
            throw BackupError.hexStringToDataFailed
        }
        
        try await api?.write(content: data, to: MultiBackupManager.backupFileName)
    }
    
    func getCurrentDriveItems() async throws -> [MultiBackupManager.StoreItem] {
        try await prepare()
        
        guard let fileId = try await api?.getFileId(fileName: MultiBackupManager.backupFileName) else {
            return []
        }
        
        guard let data = try await api?.getFileData(fileId: fileId), !data.isEmpty,
              let hexString = String(data: data, encoding: .utf8)?.trim()
        else {
            return []
        }
        
        // Compatible extension problem
        let quoteSet = CharacterSet(charactersIn: "\"")
        let fixedHexString = hexString.trimmingCharacters(in: quoteSet)
        
        return try MultiBackupManager.shared.decryptHexString(fixedHexString)
    }
    
    func removeItem(password: String) async throws {
        try await prepare()
        
        let list = try await getCurrentDriveItems()
        let newList = try await MultiBackupManager.shared.removeCurrent(list, password: password)
        let encrypedString = try MultiBackupManager.shared.encryptList(newList)
        guard let data = encrypedString.data(using: .utf8), !data.isEmpty else {
            throw BackupError.hexStringToDataFailed
        }
        
        try await api?.write(content: data, to: MultiBackupManager.backupFileName)
    }
}

extension MultiBackupGoogleDriveTarget {
    private func prepare() async throws {
        if isPrepared {
            return
        }
        
        var user = try await googleUserLogin()
        user = try await addScopesIfNeeded(user: user)
        createGoogleDriveService(user: user)
    }
    
    private func googleRestoreLogin() async throws -> GIDGoogleUser {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                    guard let signInUser = user else {
                        continuation.resume(throwing: error ?? GoogleBackupError.missingLoginUser)
                        return
                    }
                    
                    continuation.resume(returning: signInUser)
                }
            }
        }
    }
    
    private func googleUserLogin() async throws -> GIDGoogleUser {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                let topVC = Router.topPresentedController()
                GIDSignIn.sharedInstance.signIn(with: self.config, presenting: topVC) { user, error in
                    guard let signInUser = user else {
                        continuation.resume(throwing: error ?? GoogleBackupError.missingLoginUser)
                        return
                    }
                    
                    continuation.resume(returning: signInUser)
                }
            }
        }
    }
    
    private func checkUserScopes(user: GIDGoogleUser) -> Bool {
        let driveScope = kGTLRAuthScopeDriveAppdata
        if let grantedScopes = user.grantedScopes, grantedScopes.contains(driveScope) {
            return true
        }
        
        return false
    }
    
    private func addScopesIfNeeded(user: GIDGoogleUser) async throws -> GIDGoogleUser {
        guard let topVC = await UIApplication.shared.topMostViewController else {
            throw BackupError.topVCNotFound
        }
        
        if checkUserScopes(user: user) {
            return user
        }
        
        let driveScope = kGTLRAuthScopeDriveAppdata
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                GIDSignIn.sharedInstance.addScopes([driveScope], presenting: topVC) { grantedUser, error in
                    guard let grantedUser = grantedUser else {
                        continuation.resume(throwing: error ?? GoogleBackupError.missingLoginUser)
                        return
                    }
                    
                    guard let scopes = grantedUser.grantedScopes, scopes.contains(driveScope) else {
                        continuation.resume(throwing: GoogleBackupError.noDriveScope)
                        return
                    }
                    
                    continuation.resume(returning: grantedUser)
                }
            }
        }
    }
    
    private func createGoogleDriveService(user: GIDGoogleUser) {
        let service = GTLRDriveService()
        service.authorizer = user.authentication.fetcherAuthorizer()
        
        api = GoogleDriveAPI(user: user, service: service)
        
        user.authentication.do { [weak self] authentication, error in
            guard error == nil else { return }
            guard let authentication = authentication else { return }
            
            let authorizer = authentication.fetcherAuthorizer()
            let service = GTLRDriveService()
            service.authorizer = authorizer
            self?.api = GoogleDriveAPI(user: user, service: service)
        }
    }
}
