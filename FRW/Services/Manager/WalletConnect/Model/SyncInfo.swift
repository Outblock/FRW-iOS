//
//  SyncInfo.swift
//  FRW
//
//  Created by cat on 2023/12/5.
//

import Foundation


struct SyncInfo {
    
    struct SyncResponse<T: Codable>: Codable {
        var method: String?
        var status: String?
        var message: String?
        var data: T?
    }
    
    struct User: Codable {
        var userAvatar: String?
        var userName: String?
        var walletAddress: String?
        var userId: String?
    }
    
    struct DeviceInfo: Codable {
        let accountKey: AccountKey
        let deviceInfo: DeviceInfoRequest
        let backupInfo: BackupInfoModel?
    }
}
