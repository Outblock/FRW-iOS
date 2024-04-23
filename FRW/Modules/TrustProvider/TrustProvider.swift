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
        let address = EVMAccountManager.shared.accounts.first?.address ?? ""
        let config = TrustWeb3Provider.Config.EthereumConfig(address: address, chainId: chainId(), rpcUrl: rpcUrl())
        return TrustWeb3Provider(config: .init(ethereum: config))
    }
    
    static private func chainId() -> Int {
        return 646
    }
    
    static private func rpcUrl() -> String {
        return "https://previewnet.evm.nodes.onflow.org"
    }
    
}


