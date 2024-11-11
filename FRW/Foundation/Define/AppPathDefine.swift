//
//  AppPathDefine.swift
//  Flow Wallet
//
//  Created by Selina on 8/6/2023.
//

import Foundation

// MARK: - AppPathProtocol

protocol AppPathProtocol {
    var url: URL { get }
    var isExist: Bool { get }

    func remove() throws
    func createFolderIfNeeded()
}

extension AppPathProtocol {
    var isExist: Bool {
        FileManager.default.fileExists(atPath: url.relativePath)
    }

    func remove() throws {
        if !isExist {
            return
        }

        try FileManager.default.removeItem(at: url)
    }
}

// MARK: - AppFolderProtocol

protocol AppFolderProtocol: AppPathProtocol {}

extension AppFolderProtocol {
    func createFolderIfNeeded() {
        if isExist {
            return
        }

        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            log.error("create folder failed", context: error)
        }
    }
}

// MARK: - AppFileProtocol

protocol AppFileProtocol: AppPathProtocol {}

extension AppFileProtocol {
    func createFolderIfNeeded() {
        let folder = url.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: folder.relativePath) {
            do {
                try FileManager.default.createDirectory(
                    at: folder,
                    withIntermediateDirectories: true
                )
            } catch {
                log.error("create folder failed", context: error)
            }
        }
    }
}

// MARK: - AppFolderType

enum AppFolderType: AppFolderProtocol {
    case applicationSupport
    case accountInfoRoot // ./account_info
    case userStorage(String) // ./account_info/1234

    // MARK: Internal

    var url: URL {
        switch self {
        case .applicationSupport:
            return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .first!
        case .accountInfoRoot:
            return AppFolderType.applicationSupport.url.appendingPathComponent("account_info")
        case let .userStorage(uid):
            return AppFolderType.accountInfoRoot.url.appendingPathComponent(uid)
        }
    }
}

// MARK: - UserStorageFileType

enum UserStorageFileType: AppFileProtocol {
    case userInfo(String) // ./account_info/1234/user_info
    case walletInfo(String) // ./account_info/1234/wallet_info
    case userDefaults(String) // ./account_info/1234/user_defaults
    case childAccounts(String, String) // ./account_info/1234/0x12345678/child_accounts

    // MARK: Internal

    var url: URL {
        switch self {
        case let .userInfo(uid):
            return AppFolderType.userStorage(uid).url.appendingPathComponent("user_info")
        case let .walletInfo(uid):
            return AppFolderType.userStorage(uid).url.appendingPathComponent("wallet_info")
        case let .userDefaults(uid):
            return AppFolderType.userStorage(uid).url.appendingPathComponent("user_defaults")
        case let .childAccounts(uid, address):
            return AppFolderType.userStorage(uid).url.appendingPathComponent(address)
                .appendingPathComponent("child_accounts")
        }
    }
}
