//
//  UserRequests.swift
//  Lilico
//
//  Created by Selina on 9/6/2022.
//

import Foundation

struct RegisterRequest: Codable {
    let username: String
    let accountKey: AccountKey
}

struct AccountKey: Codable {
    let hashAlgo: Int
    let publicKey: String
    let sign_algo: Int
    var weight: Int = 1000
}

struct LoginRequest: Codable {
    let publicKey: String
    let signature: String
}
