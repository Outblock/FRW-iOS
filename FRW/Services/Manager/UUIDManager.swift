//
//  UUIDManager.swift
//  FRW
//
//  Created by cat on 2023/10/25.
//

import SwiftUI
import KeychainAccess


struct UUIDManager {
    static func appUUID() -> String {
        var service = Bundle.main.bundleIdentifier ?? "io.outblock.lilico"
        service += ".uuid"
        let mainKeychain = Keychain(service:service)
            .label("Flow Core UUID")
            .synchronizable(false)
            .accessibility(.whenUnlocked)
        let applicationUUID = (UIDevice.current.identifierForVendor?.uuidString)!
        do {
            let uuid = try mainKeychain.getString("uuid")
            return uuid ?? applicationUUID
        }catch {
            return applicationUUID
        }
    }
}
