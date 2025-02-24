//
//  TokenManager.swift
//  FRW
//
//  Created by Hao Fu on 22/2/2025.
//

import Foundation
import Web3Core
import Flow

class TokenBalanceHandler {
    
    // Default Flow token metadata from token list
    // https://github.com/Outblock/token-list-jsons/blob/outblock/jsons/mainnet/flow/default.json#L6-L35
    static let flowTokenJsonStr =
    """
    {
      "chainId": 747,
      "address": "0x1654653399040a61",
      "contractName": "",
      "path": {
        "vault": "/storage/flowTokenVault",
        "receiver": "/public/flowTokenReceiver",
        "balance": "/public/flowTokenBalance"
      },
      "symbol": "FLOW",
      "name": "Flow",
      "description": "",
      "decimals": 18,
      "logoURI": "https://cdn.jsdelivr.net/gh/FlowFans/flow-token-list@main/token-registry/A.1654653399040a61.FlowToken/logo.svg",
      "tags": [
        "Verified",
        "Featured",
        "utility-token"
      ],
      "extensions": {
        "coingeckoId": "flow",
        "discord": "http://discord.gg/flow",
        "documentation": "https://developers.flow.com/references/core-contracts/flow-token",
        "github": "https://github.com/onflow/flow-core-contracts",
        "twitter": "https://twitter.com/flow_blockchain",
        "website": "https://flow.com/",
        "displaySource": "0xa2de93114bae3e73",
        "pathSource": "0xa2de93114bae3e73"
      }
    }
    """
    
    static let data = flowTokenJsonStr.data(using: .utf8)!
    static let flowToken = try! FRWAPI.jsonDecoder.decode(SingleToken.self, from: data)
    static let shared = TokenBalanceHandler()
    
    private init() {}
    
    func getFTBalance(address: FWAddress, network: FlowNetworkType = LocalUserDefaults.shared.flowNetwork ) async throws  -> [TokenModel] {
        switch address.type {
        case .cadence:
            guard let cadenceAddress = address as? Flow.Address else {
                throw EVMError.addressError
            }
            let provider = CadenceTokenBalanceProvider(network: network)
            return try await provider.getFTBalance(address: cadenceAddress)
        case .evm:
            guard let evmAddress = address as? EthereumAddress else {
                throw EVMError.addressError
            }
            let provider = EVMTokenBalanceProvider(network: network)
            return try await provider.getFTBalance(address: evmAddress)
        }
    }
    
    func getFTBalanceWithId(address: FWAddress, network: FlowNetworkType = LocalUserDefaults.shared.flowNetwork, tokenId: String) async throws -> TokenModel? {
        let models = try await getFTBalance(address: address, network: network)
        return models.first{ $0.id == tokenId }
    }
}
