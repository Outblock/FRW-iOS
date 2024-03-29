//
//  TrustProvider.swift
//  FRW
//
//  Created by cat on 2024/3/4.
//

import Foundation
import TrustWeb3Provider
import WalletCore

extension TrustWeb3Provider {
    static func createEthereum(address: String, chainId: Int, rpcUrl: String) -> TrustWeb3Provider {
        return TrustWeb3Provider(config: .init(ethereum: .init(address: address, chainId: chainId, rpcUrl: rpcUrl)))
    }
    
    static func config(at index: Int = 0) -> TrustWeb3Provider {
        var address = EVMAccountManager.shared.accounts.first?.address ?? ""
        address = "0x0000000000000000000000029a9d22fe53a8fc9f"
        let config = TrustWeb3Provider.Config.EthereumConfig(address: address, chainId: 646, rpcUrl: "https://previewnet.evm.nodes.onflow.org")
        return TrustWeb3Provider(config: .init(ethereum: config))
    }
    
}


