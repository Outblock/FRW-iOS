//
//  TokenModel.swift
//  Flow Wallet
//
//  Created by Hao Fu on 30/4/2022.
//

import Flow
import Foundation


// MARK: - Coin

enum QuoteMarket: String {
    case binance
    case kraken
    case huobi

    var flowPricePair: String {
        switch self {
        case .kraken:
            return "flowusd"
        default:
            return "flowusdt"
        }
    }

    var usdcPricePair: String {
        switch self {
        case .kraken:
            return "usdcusd"
        default:
            return "usdcusdt"
        }
    }
    
    var iconName: String {
        return self.rawValue
    }
}

enum ListedToken: String, CaseIterable {
    case flow
    case fusd
    case stFlow
    case usdc
    case other
    
    enum PriceAction {
        case fixed(price: Decimal)
        case query(String)
        case mirror(ListedToken)
    }
    
    var priceAction: PriceAction {
        switch self {
        case .flow:
            return .query(LocalUserDefaults.shared.market.flowPricePair)
        case .fusd:
            return .fixed(price: 1.0)
        case .stFlow:
            return .fixed(price: 1.0)
        case .usdc:
            return .fixed(price: 1.0)
        case .other:
            return .fixed(price: 0.0)
        }
    }
    
    init?(rawValue: String) {
        if let item = ListedToken.allCases.first(where: { $0.rawValue.lowercased() == rawValue.lowercased() }) {
            self = item
        } else {
            self = .other
        }
    }
}

struct TokenModel: Codable, Identifiable, Mockable {
    let name: String
    var address: FlowNetworkModel
    let contractName: String
    let storagePath: FlowTokenStoragePath
    let decimal: Int
    let icon: URL?
    let symbol: String?
    let website: URL?
    let evmAddress: String?
    var flowIdentifier: String?
    
    var listedToken: ListedToken? {
        ListedToken(rawValue: symbol ?? "")
    }
    
    var isFlowCoin: Bool {
        return symbol?.lowercased() ?? "" == ListedToken.flow.rawValue
    }
    
    var contractId: String {
        var addressString = ""
        
        switch LocalUserDefaults.shared.flowNetwork {
        case .testnet:
            addressString = address.testnet ?? ""
        case .mainnet:
            addressString = address.mainnet ?? ""
        case .previewnet:
            addressString = address.previewnet ?? ""
        }
        
        addressString = addressString.stripHexPrefix()
        return "A.\(addressString).\(contractName)"
    }
    
    var iconURL: URL {
        if let logoString = icon?.absoluteString {
            if logoString.hasSuffix("svg") {
                return logoString.convertedSVGURL() ?? URL(string: placeholder)!
            }
            
            return URL(string: logoString) ?? URL(string: placeholder)!
        }
        
        return URL(string: placeholder)!
    }
    
    var id: String {
        return symbol ?? ""
    }

    func getAddress() -> String? {
        return address.addressByNetwork(LocalUserDefaults.shared.flowNetwork.toFlowType())
    }

    func getPricePair(market: QuoteMarket) -> String {
        switch listedToken {
        case .flow:
            return market.flowPricePair
        case .usdc:
            return market.usdcPricePair
        default:
            return market.flowPricePair //TODO: #six Need to confirm
        }
    }
    
    var isActivated: Bool {
        if let symbol = symbol {
            return WalletManager.shared.isTokenActivated(symbol: symbol)
        }
        
        return false
    }
    
    static func mock() -> TokenModel {
        return TokenModel(name: "mockname",
                          address: FlowNetworkModel(mainnet: nil, testnet: nil, crescendo: nil, previewnet: nil),
                          contractName: "contractname",
                          storagePath: FlowTokenStoragePath(balance: "", vault: "", receiver: ""),
                          decimal: 999,
                          icon: nil,
                          symbol: randomString(),
                          website: nil,
                          evmAddress: nil,
                          flowIdentifier: nil
        )
    }
}

extension TokenModel {
    func evmBridgeAddress() -> String? {
        guard let addr = flowIdentifier?.split(separator: ".")[1] else {
            return nil
        }
        return String(addr).addHexPrefix()
    }
    
    func evmBridgeContractName() -> String? {
        guard let name = flowIdentifier?.split(separator: ".")[2] else {
            return nil
        }
        return String(name)
    }
}

struct FlowNetworkModel: Codable {
    let mainnet: String?
    var testnet: String?
    let crescendo: String?
    var previewnet: String?

    func addressByNetwork(_ network: Flow.ChainID) -> String? {
        switch network {
        case .mainnet:
            return mainnet
        case .testnet:
            return testnet
        case .previewnet:
            return previewnet
        default:
            return nil
        }
    }
}

struct FlowTokenStoragePath: Codable {
    let balance: String
    let vault: String
    let receiver: String
}

struct SingleTokenResponse: Codable {
    let name: String
    let network: String
    let chainId: Int
    let tokens: [SingleToken]

    
    func conversion() -> [TokenModel] {
        let network = LocalUserDefaults.shared.flowNetwork
        let result = tokens.map { $0.toTokenModel(network: network) }
        return result
    }
    
}

struct SingleToken: Codable {
    let chainId: Int
    let address: String
    let contractName: String
    let path: FlowTokenStoragePath
    let symbol: String?
    let name: String
    let decimals: Int
    let logoURI: URL?
    let extensions: TokenExtension?
    let evmAddress: String?
    
    func toTokenModel(network: LocalUserDefaults.FlowNetworkType) -> TokenModel {
        
        let model = TokenModel(name: name, 
                               address: FlowNetworkModel(mainnet: network == .mainnet ? address : nil, testnet: network == .testnet ? address : nil, crescendo: nil, previewnet: network == .previewnet ? address : nil),
                               contractName: contractName, storagePath: path, decimal: decimals, icon: logoURI, symbol: symbol, website: extensions?.website, evmAddress: evmAddress, flowIdentifier: nil)
        return model
    }
}

struct TokenExtension: Codable {
    let website: URL?
    let twitter: URL?
    let discord: URL?
    
    enum CodingKeys: String, CodingKey {
        case website
        case twitter
        case discord
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        website = try? container.decode(URL.self, forKey: .website)
        twitter = try? container.decode(URL.self, forKey: .twitter)
        discord = try? container.decode(URL.self, forKey: .discord)
    }
}
