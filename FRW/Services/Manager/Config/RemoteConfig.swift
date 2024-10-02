//
//  RemoteConfig.swift
//  Flow Wallet
//
//  Created by Hao Fu on 5/9/2022.
//

import Foundation

extension RemoteConfigManager {
    struct ContractAddress: Codable {
        let mainnet: [String: String]?
        let testnet: [String: String]?
        let crescendo: [String: String]?
        let previewnet: [String: String]?
    }
    
    struct ENVConfig: Codable {
        let version: String
        let prod: Config
        let staging: Config
    }
    
    struct Config: Codable {
        let features: Features
        let payer: Payer
    }
    
    // MARK: - Features

    struct Features: Codable {
        let freeGas: Bool
        let walletConnect: Bool
        let onRamp: Bool?
        let appList: Bool?
        let swap: Bool?
        let browser: Bool?
        let nftTransfer: Bool?
        let hideBrowser: Bool?

        enum CodingKeys: String, CodingKey {
            case freeGas = "free_gas"
            case walletConnect = "wallet_connect"
            case onRamp = "on_ramp"
            case appList = "app_list"
            case swap
            case browser
            case nftTransfer = "nft_transfer"
            case hideBrowser = "hide_browser"
        }
    }

    // MARK: - Payer

    struct Payer: Codable {
        let mainnet: PayerInfo
        let testnet: PayerInfo
        let crescendo: PayerInfo?
        let previewnet: PayerInfo?
    }

    // MARK: - Net

    struct PayerInfo: Codable {
        let address: String
        let keyID: Int

        enum CodingKeys: String, CodingKey {
            case address
            case keyID = "keyId"
        }
    }

    // MARK: - News

    enum NewsType: String, Codable {
        case message
        case image
        
        case undefined
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try? container.decode(String.self)
            self = NewsType(rawValue: rawValue ?? "") ?? .undefined
        }
    }

    enum NewsPriority: String, Codable, Comparable {
        case low
        case medium
        case high
        case urgent
        
        private var level: Int {
            switch self {
            case .low:
                return 100
            case .medium:
                return 500
            case .high:
                return 750
            case .urgent:
                return 1000
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try? container.decode(String.self)
            self = NewsPriority(rawValue: rawValue ?? "") ?? .low
        }
        
        static func < (lhs: RemoteConfigManager.NewsPriority, rhs: RemoteConfigManager.NewsPriority) -> Bool {
            return lhs.level < rhs.level
        }
    }

    enum NewDisplayType: String, Codable {
        case once // 只显示一次
        case click // 用户点击，或者关闭后，不再显示
        case expiry // 一直显示直到过期，用户关闭后，下次启动再显示
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try? container.decode(String.self)
            self = NewDisplayType(rawValue: rawValue ?? "") ?? .expiry
        }
    }
    
    enum NewsFlag: String, Codable {
        case normal
        case walletconnect
        case upgrade
    }

    struct News: Codable, Comparable, Identifiable, Hashable {
        let id: String
        let priority: NewsPriority
        let type: NewsType
        let title: String
        let body: String?
        /// Do not use this property directly, call 'iconURL'
        let icon: String?
        let image: String?
        let url: String?
        let expiryTime: Date
        let displayType: NewDisplayType
        
        var flag: NewsFlag? = .normal

        var iconURL: URL? {
            if let logoString = icon {
                if logoString.hasSuffix("svg") {
                    return logoString.convertedSVGURL()
                }
                return URL(string: logoString)
            }
            return nil
        }
        
        static func < (lhs: RemoteConfigManager.News, rhs: RemoteConfigManager.News) -> Bool {
            lhs.priority < rhs.priority
        }
    }
}
