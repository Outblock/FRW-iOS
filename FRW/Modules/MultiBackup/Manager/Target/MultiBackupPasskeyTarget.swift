//
//  MultiBackupPasskeyTarget.swift
//  FRW
//
//  Created by cat on 2024/1/25.
//

import Foundation

class MultiBackupPasskeyTarget: MultiBackupTarget {
    var uploadedItem: MultiBackupManager.StoreItem?
    
    var registeredDeviceInfo: SyncInfo.DeviceInfo?
    
    func loginCloud() async throws {
            
    }
    
    func upload(password: String) async throws {
            
    }
    
    func getCurrentDriveItems() async throws -> [MultiBackupManager.StoreItem] {
        return []
    }
    
    func removeItem(password: String) async throws {
            
    }
    
    
}
