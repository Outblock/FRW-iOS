//
//  EVMResponse.swift
//  FRW
//
//  Created by cat on 2024/4/29.
//

import Foundation
import web3swift
import Web3Core
import BigInt

struct EVMTokenResponse: Codable {
    let chainId: Int
    let address: String
    let symbol: String
    let name: String
    let decimals: Int
    let logoURI: String
    let balance: String?
    let flowIdentifier: String?
    

    func toTokenModel() -> TokenModel {
        
        let model = TokenModel(name: name,
                               address: FlowNetworkModel(mainnet: nil, testnet: nil, crescendo: nil, previewnet: address),
                               contractName: "",
                               storagePath: FlowTokenStoragePath(balance: "", vault: "", receiver: ""),
                               decimal: decimals,
                               icon: .init(string: logoURI),
                               symbol: symbol,
                               website: nil, evmAddress: nil, flowIdentifier: flowIdentifier)
        return model
    }
    
    var flowBalance: Double {
        guard let bal = balance, let value = BigUInt(bal) else {
            return 0
        }
        return Utilities.formatToPrecision(value, formattingDecimals: decimals).doubleValue
    }
}

struct EVMCollection: Codable {
    let chainId: Int
    let address: String
    let symbol: String
    let name: String
    let tokenURI: String
    let logoURI: String
    let balance: String?
    let flowIdentifier: String?
    let nftIds: [String]
    let nfts: [EVMNFT]
}

struct EVMNFT: Codable {
    let id: String
    let name: String
    let thumbnail: String
}
