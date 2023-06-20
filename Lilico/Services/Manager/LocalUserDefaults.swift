//
//  LocalUserDefaultsManager.swift
//  Lilico
//
//  Created by Selina on 7/6/2022.
//

import Flow
import SwiftUI
import UIKit

var currentNetwork: LocalUserDefaults.FlowNetworkType {
    LocalUserDefaults.shared.flowNetwork
}

extension LocalUserDefaults {
    enum Keys: String {
        case activatedUID
        case flowNetwork
        case legacyUserInfo = "userInfo"
        case walletHidden
        case quoteMarket
        case coinSummary
        case recentSendByToken
        case legacyBackupType = "backupType"
        case securityType
        case lockOnExit
        case panelHolderFrame
        case transactionCount
        case customWatchAddress
        case tryToRestoreAccountFlag
        case currentCurrency
        case currentCurrencyRate
        case stakingGuideDisplayed
        case nftCount
        case onBoardingShown
        case multiAccountUpgradeFlag
        case loginUIDList
    }

    enum FlowNetworkType: String, CaseIterable {
        case testnet
        case mainnet
        case sandboxnet
        
        var color: Color {
            switch self {
            case .mainnet:
                return Color.LL.Primary.salmonPrimary
            case .testnet:
                return Color.LL.flow
            case .sandboxnet:
                return Color(hex: "#F3EA5F")
            }
        }
        
        var isMainnet: Bool {
            self == .mainnet
        }

        func toFlowType() -> Flow.ChainID {
            switch self {
            case .testnet:
                return Flow.ChainID.testnet
            case .mainnet:
                return Flow.ChainID.mainnet
            case .sandboxnet:
                return Flow.ChainID.sandboxnet
            }
        }
        
        init?(chainId: Flow.ChainID) {
            switch chainId {
            case .testnet:
                self = .testnet
            case .mainnet:
                self = .mainnet
            case .sandboxnet:
                self = .sandboxnet
            default:
                return nil
            }
        }
    }
}

extension Flow.ChainID {
    var networkType: LocalUserDefaults.FlowNetworkType? {
        .init(chainId: self)
    }
}

class LocalUserDefaults: ObservableObject {
    static let shared = LocalUserDefaults()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(willReset), name: .willResetWallet, object: nil)
    }

    #if DEBUG
        @AppStorage(Keys.flowNetwork.rawValue) var flowNetwork: FlowNetworkType = .testnet {
            didSet {
                FlowNetwork.setup()
                if WalletManager.shared.getPrimaryWalletAddress() == nil {
                    WalletManager.shared.reloadWalletInfo()
                } else {
                    WalletManager.shared.walletInfo = WalletManager.shared.walletInfo
                }
                
                NotificationCenter.default.post(name: .networkChange)
            }
        }
    #else
        @AppStorage(Keys.flowNetwork.rawValue) var flowNetwork: FlowNetworkType = .mainnet {
            didSet {
                FlowNetwork.setup()
                if WalletManager.shared.getPrimaryWalletAddress() == nil {
                    WalletManager.shared.reloadWalletInfo()
                } else {
                    WalletManager.shared.walletInfo = WalletManager.shared.walletInfo
                    StakingManager.shared.refresh()
                }
                
                NotificationCenter.default.post(name: .networkChange)
            }
        }
    #endif
    
    @AppStorage(Keys.activatedUID.rawValue) var activatedUID: String?

    var legacyUserInfo: UserInfo? {
        set {
            if let value = newValue, let data = try? LilicoAPI.jsonEncoder.encode(value) {
                UserDefaults.standard.set(data, forKey: Keys.legacyUserInfo.rawValue)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.legacyUserInfo.rawValue)
            }
        }
        get {
            if let data = UserDefaults.standard.data(forKey: Keys.legacyUserInfo.rawValue), let info = try? LilicoAPI.jsonDecoder.decode(UserInfo.self, from: data) {
                return info
            } else {
                return nil
            }
        }
    }

    @AppStorage(Keys.walletHidden.rawValue) var walletHidden: Bool = false {
        didSet {
            NotificationCenter.default.post(name: .walletHiddenFlagUpdated, object: nil)
        }
    }

    @AppStorage(Keys.quoteMarket.rawValue) var market: QuoteMarket = .binance {
        didSet {
            NotificationCenter.default.post(name: .quoteMarketUpdated, object: nil)
        }
    }

    var coinSummarys: [CoinRateCache.CoinRateModel]? {
        set {
            if let value = newValue, let data = try? LilicoAPI.jsonEncoder.encode(value) {
                UserDefaults.standard.set(data, forKey: Keys.coinSummary.rawValue)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.coinSummary.rawValue)
            }
        }
        get {
            if let data = UserDefaults.standard.data(forKey: Keys.coinSummary.rawValue), let info = try? LilicoAPI.jsonDecoder.decode([CoinRateCache.CoinRateModel].self, from: data) {
                return info
            } else {
                return nil
            }
        }
    }
    
    @AppStorage(Keys.recentSendByToken.rawValue) var recentToken: String?
    
    @AppStorage(Keys.legacyBackupType.rawValue) var legacyBackupType: BackupManager.BackupType = .none
    
    @AppStorage(Keys.securityType.rawValue) var securityType: SecurityManager.SecurityType = .none
    @AppStorage(Keys.lockOnExit.rawValue) var lockOnExit: Bool = false
    
    var panelHolderFrame: CGRect? {
        set {
            if let value = newValue {
                let str = NSCoder.string(for: value)
                UserDefaults.standard.set(str, forKey: Keys.panelHolderFrame.rawValue)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.panelHolderFrame.rawValue)
            }
        }
        get {
            if let str = UserDefaults.standard.string(forKey: Keys.panelHolderFrame.rawValue) {
                return NSCoder.cgRect(for: str)
            } else {
                return nil
            }
        }
    }
    
    @AppStorage(Keys.transactionCount.rawValue) var transactionCount: Int = 0 {
        didSet {
            NotificationCenter.default.post(name: .transactionCountDidChanged, object: nil)
        }
    }
    
    @AppStorage(Keys.customWatchAddress.rawValue) var customWatchAddress: String? {
        didSet {
            NotificationCenter.default.post(name: .watchAddressDidChanged, object: nil)
        }
    }
    
    @AppStorage(Keys.tryToRestoreAccountFlag.rawValue) var tryToRestoreAccountFlag: Bool = false
    
    @AppStorage(Keys.currentCurrency.rawValue) var currentCurrency: Currency = .USD
    @AppStorage(Keys.currentCurrencyRate.rawValue) var currentCurrencyRate: Double = 1
    
    @AppStorage(Keys.stakingGuideDisplayed.rawValue) var stakingGuideDisplayed: Bool = false
    
    @AppStorage(Keys.nftCount.rawValue) var nftCount: Int = 0 {
        didSet {
            NotificationCenter.default.post(name: .nftCountChanged, object: nil)
        }
    }
    
    @AppStorage(Keys.onBoardingShown.rawValue) var onBoardingShown: Bool = false
    @AppStorage(Keys.multiAccountUpgradeFlag.rawValue) var multiAccountUpgradeFlag: Bool = false
    
    var loginUIDList: [String] {
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.loginUIDList.rawValue)
        }
        get {
            return UserDefaults.standard.array(forKey: Keys.loginUIDList.rawValue) as? [String] ?? []
        }
    }
}

extension LocalUserDefaults {
    @objc private func willReset() {
        self.recentToken = nil
        self.flowNetwork = .mainnet
    }
}
