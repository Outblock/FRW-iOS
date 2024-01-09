//
//  KeyResponse.swift
//  FRW
//
//  Created by cat on 2023/11/2.
//

import Foundation

struct KeyResponse: Codable {
    let result: [KeyDeviceModel]
}

struct KeyDeviceModel: Codable {
    let device: DeviceInfoModel
    let pubkey: PubkeyModel
    let backupInfo: BackupInfoModel?
}

struct PubkeyModel: Codable {
    let hashAlgo: Int
    let publicKey: String
    let signAlgo: Int
    var weight: Int = 1000
    var name: String?
}

struct BackupInfoModel: Codable {
    let create_time: String?
    let name: String?
    var type: BackupType = .undefined
    var keyIndex: Int? = 0
}

enum BackupType: Int,Codable {
    case google = 0
    case iCloud = 1
    case manual = 2
    case passkey = 3
    case undefined = 100
}
