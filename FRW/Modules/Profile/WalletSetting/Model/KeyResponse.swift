//
//  KeyResponse.swift
//  FRW
//
//  Created by cat on 2023/11/2.
//

import Foundation

struct KeyResponse: Codable {
    let result: [KeyDeviceModel]?
}

struct KeyDeviceModel: Codable {
    let device: DeviceInfoModel
    let pubkey: PubkeyModel
    var backupInfo: BackupInfoModel?
}

struct PubkeyModel: Codable {
    let hashAlgo: Int
    let publicKey: String
    let signAlgo: Int
    var weight: Int = 1000
    var name: String?
}

struct BackupInfoModel: Codable {
    let createTime: String?
    let name: String?
    var type: Int
    var keyIndex: Int? = 0

    func backupType() -> BackupType {
        switch type {
        case 0:
            return .google
        case 1:
            return .iCloud
        case 2:
            return .manual
        case 3:
            return .passkey
        default:
            return .undefined
        }
    }

    func showDate() -> String {
        guard let created = createTime else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"
        let date = dateFormatter.date(from: created)
        guard let date = date else { return "" }
        dateFormatter.dateFormat = "MMMM dd,yyyy"
        let res = dateFormatter.string(from: date)
        return res
    }
}

enum BackupType: Int, Codable {
    case undefined = -1
    case google = 0
    case iCloud = 1
    case manual = 2
    case passkey = 3

    var title: String {
        switch self {
        case .google:
            return "google_drive".localized
        case .passkey:
            return "Passkey"
        case .iCloud:
            return "iCloud"
        case .manual:
            return "Recovery Phrase"
        default:
            return "Undefined"
        }
    }
    
    var smallIcon: String {
        switch self {
        case .google:
            return "icon_key_google"
        case .iCloud:
            return "icon_key_icloud"
        case .manual:
            return "icon_key_phrase"
        case .passkey:
            return ""
        case .undefined:
            return ""
        }
    }
}
