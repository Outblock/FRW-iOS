//
//  MultiBackupiCloudTarget.swift
//  FRW
//
//  Created by cat on 2024/1/6.
//

import Foundation

import SwiftUI
import UIKit

// MARK: - MultiBackupiCloudTarget

class MultiBackupiCloudTarget: MultiBackupTarget {
    // MARK: Internal

    var uploadedItem: MultiBackupManager.StoreItem?
    var registeredDeviceInfo: SyncInfo.DeviceInfo?

    var isPrepared: Bool {
        api != nil
    }

    func loginCloud() async throws {}

    func clearCloud() async throws {
        try await prepare()
        let encrypedString = try MultiBackupManager.shared.encryptList([])
        guard let data = encrypedString.data(using: .utf8), !data.isEmpty else {
            throw BackupError.hexStringToDataFailed
        }

        let result = try await api!.write(content: data)
    }

    func upload(password: String) async throws {
        try await prepare()

        var list = [MultiBackupManager.StoreItem]()
        do {
            list = try await getCurrentDriveItems()
        } catch BackupError.fileIsNotExistOnCloud {
            // it's ok
        }

        let newList = try await MultiBackupManager.shared.addNewMnemonic(
            on: .icloud,
            list: list,
            password: password
        )
        let encrypedString = try MultiBackupManager.shared.encryptList(newList)
        guard let data = encrypedString.data(using: .utf8), !data.isEmpty else {
            throw BackupError.hexStringToDataFailed
        }

        let result = try await api!.write(content: data)
        if !result {
            throw iCloudBackupError.saveToDataFailed
        }
    }

    func getCurrentDriveItems() async throws -> [MultiBackupManager.StoreItem] {
        try await prepare()

        let exist = try await api!.isExist(name: MultiBackupManager.backupFileName)
        if !exist {
            log.error("[iCloud] Multiple backup file not found.")
            return []
        }

        guard let data = try await api?.getFileData(), !data.isEmpty,
              let hexString = String(data: data, encoding: .utf8)?.trim()
        else {
            log.error("[iCloud] Unable to decode backup file.")
            throw BackupError.cloudFileData
        }

        return try MultiBackupManager.shared.decryptHexString(hexString)
    }

    func removeItem(password: String) async throws {
        try await prepare()

        var list = [MultiBackupManager.StoreItem]()
        do {
            list = try await getCurrentDriveItems()
        } catch BackupError.fileIsNotExistOnCloud {
            // it's ok
        }

        let newList = try await MultiBackupManager.shared.removeCurrent(list, password: password)
        let encrypedString = try MultiBackupManager.shared.encryptList(newList)
        guard let data = encrypedString.data(using: .utf8), !data.isEmpty else {
            throw BackupError.hexStringToDataFailed
        }

        let result = try await api!.write(content: data)
        if !result {
            throw iCloudBackupError.saveToDataFailed
        }
    }

    // MARK: Private

    private var api: iCloudAPI?
}

extension MultiBackupiCloudTarget {
    private func prepare() async throws {
        if isPrepared {
            return
        }

        guard let id = containerID,
              let url = FileManager.default.url(forUbiquityContainerIdentifier: id) else {
            throw iCloudBackupError.initError
        }

        let fileURL = url.appendingPathComponent("Documents")
            .appendingPathComponent(MultiBackupManager.backupFileName)
        api = await iCloudAPI(fileURL: fileURL)

        // double check if prepared
        if !isPrepared {
            throw iCloudBackupError.initError
        }
    }

    private var containerID: String? {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            return nil
        }

        return "iCloud.\(bundleId)"
    }
}
