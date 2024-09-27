//
//  KeyProtocol+Add.swift
//  FRW
//
//  Created by cat on 2024/9/27.
//

import Foundation

struct KeyProvider {
    static func password(with uid: String) -> String {
        let aseKey = LocalEnvManager.shared.backupAESKey
        return aseKey
    }
}
