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
}

struct PubkeyModel: Codable {
    let hashAlgo: Int
    let publicKey: String
    let signAlgo: Int
    var weight: Int = 1000
    var name: String?
}
