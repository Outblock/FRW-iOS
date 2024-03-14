//
//  MoonPayRequest.swift
//  Flow Wallet
//
//  Created by Hao Fu on 8/9/2022.
//

import Foundation

struct MoonPayRequest: Codable {
    let url: String
}

struct MoonPayResponse: Codable {
    let url: URL
}
