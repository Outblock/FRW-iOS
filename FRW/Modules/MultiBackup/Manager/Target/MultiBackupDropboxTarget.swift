//
//  MultiBackupDropboxTarget.swift
//  FRW
//
//  Created by cat on 12/17/24.
//

import Foundation
import UIKit
import SwiftyDropbox

// MARK: - MultiBackupDropboxTarget

final class MultiBackupDropboxTarget: MultiBackupTarget {
    // MARK: Lifecycle

    init() {
        if DropboxOAuthManager.sharedOAuthManager == nil {
            let appKey = ServiceConfig.shared.dropboxAppKey
            DropboxClientsManager.setupWithTeamAppKey(appKey)
        }
        path = "/" + MultiBackupManager.backupFileName
        DropboxClientsManager.unlinkClients()
    }

    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: Internal

    var uploadedItem: MultiBackupManager.StoreItem?

    var registeredDeviceInfo: SyncInfo.DeviceInfo?

    private var observer: NSObjectProtocol? = nil
    private let path: String

    var isPrepared: Bool {
        DropboxClientsManager.authorizedClient != nil
    }

    func loginCloud() async throws {
        try await startLogin()
        log.info("[Multi] dropbox is \(isPrepared)")
    }

    func upload(password: String) async throws {
        try await prepare()

        guard let client = DropboxClientsManager.authorizedClient else {
            log.info("[Multi] dropbox unauthorized")
            throw BackupError.unauthorized
        }

        let list = try await getCurrentDriveItems()
        let newList = try await MultiBackupManager.shared.addNewMnemonic(
            on: .dropbox,
            list: list,
            password: password
        )
        let encrypedString = try MultiBackupManager.shared.encryptList(newList)
        guard let data = encrypedString.data(using: .utf8), !data.isEmpty else {
            throw BackupError.hexStringToDataFailed
        }
        _ = try await uploadFile(client: client, path: path, data: data)
    }

    func getCurrentDriveItems() async throws -> [MultiBackupManager.StoreItem] {
        try await prepare()
        guard let client = DropboxClientsManager.authorizedClient else {
            log.error("[Multi] dropbox unauthorized")
            throw BackupError.unauthorized
        }

        guard let data = try? await readFile(client: client, path: path) else {
            return []
        }

        guard let hexString = String(data: data, encoding: .utf8)?.trim() else {
            return []
        }

        let quoteSet = CharacterSet(charactersIn: "\"")
        let fixedHexString = hexString.trimmingCharacters(in: quoteSet)

        return try MultiBackupManager.shared.decryptHexString(fixedHexString)
    }

    func removeItem(password: String) async throws {
        try await prepare()
        guard let client = DropboxClientsManager.authorizedClient else {
            log.info("[Multi] dropbox unauthorized")
            throw BackupError.unauthorized
        }
        let list = try await getCurrentDriveItems()
        let newList = try await MultiBackupManager.shared.removeCurrent(list, password: password)
        let encrypedString = try MultiBackupManager.shared.encryptList(newList)
        guard let data = encrypedString.data(using: .utf8), !data.isEmpty else {
            throw BackupError.hexStringToDataFailed
        }

        _ = try await uploadFile(client: client, path: path, data: data)
    }

    func startLogin() async throws {
        guard !isPrepared else {
            return
        }
        DispatchQueue.main.async {
            let scopeRequest = ScopeRequest(
                scopeType: .user,
                scopes: ["files.content.write", "files.content.read"],
                includeGrantedScopes: false
            )
            DropboxClientsManager.authorizeFromControllerV2(
                UIApplication.shared,
                controller: nil,
                loadingStatusDelegate: nil,
                openURL: { url in
                    UIApplication.shared.open(url)
                },
                scopeRequest: scopeRequest
            )
        }
        let notification = await waitForNotification(named: .dropboxCallback)
        if let authResult = notification.object as? DropboxOAuthResult {
            switch authResult {
            case .success:
                log.info("[Multi] Dropbox Success!")
            case .cancel:
                log.info("[Multi] Authorization flow was manually canceled by user!")
            case let .error(_, description):
                log.info("[Multi] dropbox Error: \(String(describing: description))")
            }
        }
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }

    private func prepare() async throws {
        guard !isPrepared else {
            return
        }
        try await startLogin()
    }
}

extension MultiBackupDropboxTarget {
    private func uploadFile(client: DropboxClient, path: String, data: Data) async throws -> Files
        .FileMetadata {
        try await withCheckedThrowingContinuation { continuation in
            client.files.upload(path: path, mode: .overwrite, input: data).response { response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                if let metadata = response {
                    log.info("[Multi] dropbox Encrypted key uploaded successfully: \(metadata)")
                    continuation.resume(returning: metadata)
                } else {
                    continuation.resume(throwing: BackupError.CloudFileData)
                }
            }
        }
    }

    private func readFile(client: DropboxClient, path: String) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            client.files.download(path: path).response { response, error in
                if let error = error {
                    log.error("[Multi] download file error: \(error)")
                    continuation.resume(throwing: error)
                    return
                }

                if let (_, data) = response {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: LLError.unknown)
                }
            }
        }
    }
}

extension MultiBackupDropboxTarget {
    func waitForNotification(
        named name: Notification.Name,
        object: AnyObject? = nil
    ) async -> Notification {
        await withCheckedContinuation { [weak self] continuation in
            self?.observer = NotificationCenter.default.addObserver(
                forName: name,
                object: object,
                queue: nil
            ) { notification in
                continuation.resume(returning: notification)
            }
        }
    }
}

