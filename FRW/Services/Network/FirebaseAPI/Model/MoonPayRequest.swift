//
//  MoonPayRequest.swift
//  Flow Wallet
//
//  Created by Hao Fu on 8/9/2022.
//

import Foundation

// MARK: - MoonPayRequest

struct MoonPayRequest: Codable {
    let url: String
}

// MARK: - MoonPayResponse

struct MoonPayResponse: Codable {
    let url: URL
}
