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

    func toTokenModel() -> TokenModel {
        let model = TokenModel(name: name,
                               address: FlowNetworkModel(mainnet: nil, testnet: nil, crescendo: nil, previewnet: address),
                               contractName: "",
                               storagePath: FlowTokenStoragePath(balance: "", vault: "", receiver: ""),
                               decimal: decimals,
                               icon: .init(string: logoURI),
                               symbol: symbol,
                               website: nil)
        return model
    }
    
    var flowBalance: Double {
        guard let bal = balance else {
            return 0
        }
        guard let value = BigUInt(from: bal) else { return 0 }
        return Utilities.formatToPrecision(value).doubleValue
    }
}
