//
//  AppPathDefine.swift
//  Lilico
//
//  Created by Selina on 8/6/2023.
//

import Foundation

protocol AppPathProtocol {
    var url: URL { get }
    var isExist: Bool { get }
    
    func remove() throws
}

protocol AppFolderProtocol: AppPathProtocol {
    func createFolderIfNeeded()
}

extension AppPathProtocol {
    var isExist: Bool {
        return FileManager.default.fileExists(atPath: self.url.relativePath)
    }
    
    func remove() throws {
        if !isExist {
            return
        }
        
        try FileManager.default.removeItem(at: url)
    }
}

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

enum AppFolderType: AppFolderProtocol {
    case applicationSupport
    case accountInfoRoot                        // ./account_info
    case userStorage(String)                    // ./account_info/1234
    
    var url: URL {
        switch self {
        case .applicationSupport:
            return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        case .accountInfoRoot:
            return AppFolderType.applicationSupport.url.appendingPathComponent("account_info")
        case .userStorage(let uid):
            return AppFolderType.accountInfoRoot.url.appendingPathComponent(uid)
        }
    }
}

enum UserStorageFileType: AppPathProtocol {
    case userInfo(String)                       // ./account_info/1234/user_info
    
    var url: URL {
        switch self {
        case .userInfo(let uid):
            return AppFolderType.userStorage(uid).url.appendingPathComponent("user_info")
        }
    }
}
