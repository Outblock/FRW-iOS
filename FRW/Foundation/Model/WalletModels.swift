//
//  WalletModels.swift
//  Flow Wallet
//
//  Created by Hao Fu on 30/4/2022.
//

import BigInt
import Flow
import Foundation

// MARK: - QuoteMarket

enum QuoteMarket: String {
    case binance
    case kraken
    case huobi

    // MARK: Internal

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
        rawValue
    }
}

// MARK: - ListedToken

enum ListedToken: String, CaseIterable {
    case flow
    case fusd
    case stFlow
    case usdc
    case other

    // MARK: Lifecycle

    init?(rawValue: String) {
        if let item = ListedToken.allCases
            .first(where: { $0.rawValue.lowercased() == rawValue.lowercased() }) {
            self = item
        } else {
            self = .other
        }
    }

    // MARK: Internal

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
}

// MARK: - TokenModel

struct TokenModel: Codable, Identifiable, Mockable {
    enum TokenType: Codable { case cadence, evm }

    let type: TokenType
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
    var balance: BigUInt?

    var listedToken: ListedToken? {
        ListedToken(rawValue: symbol ?? "")
    }

    var isFlowCoin: Bool {
        symbol?.lowercased() ?? "" == ListedToken.flow.rawValue
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
        symbol ?? ""
    }

    var isActivated: Bool {
        if let symbol = symbol {
            return WalletManager.shared.isTokenActivated(symbol: symbol)
        }

        return false
    }

    static func mock() -> TokenModel {
        TokenModel(
            type: .cadence,
            name: "mockname",
            address: FlowNetworkModel(
                mainnet: nil,
                testnet: nil,
                crescendo: nil,
                previewnet: nil
            ),
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

    func getAddress() -> String? {
        address.addressByNetwork(LocalUserDefaults.shared.flowNetwork.toFlowType())
    }

    func getPricePair(market: QuoteMarket) -> String {
        switch listedToken {
        case .flow:
            return market.flowPricePair
        case .usdc:
            return market.usdcPricePair
        default:
            return market.flowPricePair // TODO: #six Need to confirm
        }
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

// MARK: - FlowNetworkModel

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

// MARK: - FlowTokenStoragePath

struct FlowTokenStoragePath: Codable {
    let balance: String
    let vault: String
    let receiver: String
}

// MARK: - SingleTokenResponse

struct SingleTokenResponse: Codable {
    let name: String
    let network: String?
    let chainId: Int?
    let tokens: [SingleToken]

    func conversion(type: TokenModel.TokenType) -> [TokenModel] {
        let network = LocalUserDefaults.shared.flowNetwork
        let result = tokens.map { $0.toTokenModel(type: type, network: network) }
        return result
    }
}

// MARK: - SingleToken

struct SingleToken: Codable {
    let chainId: Int
    let address: String
    let contractName: String?
    let path: FlowTokenStoragePath?
    let symbol: String?
    let name: String
    let decimals: Int
    let logoURI: String?
    let extensions: TokenExtension?
    let evmAddress: String?
    let flowIdentifier: String?

    func toTokenModel(type: TokenModel.TokenType, network: LocalUserDefaults.FlowNetworkType) -> TokenModel {
        let logo = URL(string: logoURI ?? "")

        let model = TokenModel(
            type: type,
            name: name,
            address: FlowNetworkModel(
                mainnet: network == .mainnet ? address : nil,
                testnet: network == .testnet ? address : nil,
                crescendo: nil,
                previewnet: network == .previewnet ? address : nil
            ),
            contractName: contractName ?? "",
            storagePath: path ??
                FlowTokenStoragePath(balance: "", vault: "", receiver: ""),
            decimal: decimals,
            icon: logo,
            symbol: symbol,
            website: extensions?.website,
            evmAddress: evmAddress,
            flowIdentifier: flowIdentifier
        )
        return model
    }
}

// MARK: - TokenExtension

struct TokenExtension: Codable {
    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.website = try? container.decode(URL.self, forKey: .website)
        self.twitter = try? container.decode(URL.self, forKey: .twitter)
        self.discord = try? container.decode(URL.self, forKey: .discord)
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case website
        case twitter
        case discord
    }

    let website: URL?
    let twitter: URL?
    let discord: URL?
}
