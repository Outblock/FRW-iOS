//
//  BackupiCloudTarget.swift
//  Flow Wallet
//
//  Created by Selina on 28/7/2022.
//

import SwiftUI
import UIKit

actor BackupiCloudTarget: BackupTarget {
    private var api: iCloudAPI?

    var isPrepared: Bool {
        return api != nil
    }

    func uploadMnemonic(password: String) async throws {
        try await prepare()

        var list = [BackupManager.DriveItem]()
        do {
            list = try await getCurrentDriveItems()
        } catch BackupError.fileIsNotExistOnCloud {
            // it's ok
        }

        let newList = try BackupManager.shared.addCurrentMnemonicToList(list, password: password)
        let encrypedString = try BackupManager.shared.encryptList(newList)
        guard let data = encrypedString.data(using: .utf8), !data.isEmpty else {
            throw BackupError.hexStringToDataFailed
        }

        let result = try await api!.write(content: data)
        if !result {
            throw iCloudBackupError.saveToDataFailed
        }
    }

    func getCurrentDriveItems() async throws -> [BackupManager.DriveItem] {
        try await prepare()

        let exist = try await api!.isExist()
        if !exist {
            throw BackupError.fileIsNotExistOnCloud
        }

        guard let data = try await api?.getFileData(), !data.isEmpty,
              let hexString = String(data: data, encoding: .utf8)?.trim()
        else {
            return []
        }

        return try BackupManager.shared.decryptHexString(hexString)
    }
}

extension BackupiCloudTarget {
    private func prepare() async throws {
        if isPrepared {
            return
        }

        guard let id = containerID, let url = FileManager.default.url(forUbiquityContainerIdentifier: id) else {
            throw iCloudBackupError.initError
        }

        let fileURL = url.appendingPathComponent("Documents").appendingPathComponent(BackupManager.backupFileName)
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
