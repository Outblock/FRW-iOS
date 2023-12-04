//
//  UserRequests.swift
//  Flow Reference Wallet
//
//  Created by Selina on 9/6/2022.
//

import Foundation

struct RegisterRequest: Codable {
    let username: String?
    let accountKey: AccountKey
    let deviceInfo: DeviceInfoRequest
}

struct AccountKey: Codable {
    let hashAlgo: Int
    let publicKey: String
    let signAlgo: Int
    var weight: Int = 1000
}

struct LoginRequest: Codable {
//    let publicKey: String
    let signature: String
    let accountKey: AccountKey
    let deviceInfo: DeviceInfoRequest
}

struct DeviceInfoRequest: Codable {
    let deviceId: String
    let ip: String
    let name: String
    let type: String
    let userAgent: String

    let continent: String?
    let continentCode: String?
    let country: String?
    let countryCode: String?
    let regionName: String?
    let city: String?
    let district: String?
    let zip: String?
    let lat: Double?
    let lon: Double?
    let timezone: String?
    let currency: String?
    let isp: String?
    let org: String?
}
