//
//  KeyProtocol+Add.swift
//  FRW
//
//  Created by cat on 2024/9/27.
//

import Foundation

enum KeyProvider {
    static func password(with _: String) -> String {
        let aseKey = LocalEnvManager.shared.backupAESKey
        return aseKey
    }
}
