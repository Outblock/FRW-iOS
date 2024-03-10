//
//  TrustProvider.swift
//  FRW
//
//  Created by cat on 2024/3/4.
//

import Foundation
import TrustWeb3Provider

extension TrustWeb3Provider {
    static func createEthereum(address: String, chainId: Int, rpcUrl: String) -> TrustWeb3Provider {
        return TrustWeb3Provider(config: .init(ethereum: .init(address: address, chainId: chainId, rpcUrl: rpcUrl)))
    }
    
    static func config(at index: Int = 0) -> TrustWeb3Provider {
        return TrustWeb3Provider(config: .init(ethereum: ethereumConfigs[index]))
    }
    
    static var ethereumConfigs = [
        TrustWeb3Provider.Config.EthereumConfig(
            address: "0x9d8a62f656a8d1615c1294fd71e9cfb3e4855a4f",
            chainId: 1,
            rpcUrl: "https://cloudflare-eth.com"
        ),
        TrustWeb3Provider.Config.EthereumConfig(
            address: "0x9d8a62f656a8d1615c1294fd71e9cfb3e4855a4f",
            chainId: 10,
            rpcUrl: "https://mainnet.optimism.io"
        ),
        TrustWeb3Provider.Config.EthereumConfig(
            address: "0x9d8a62f656a8d1615c1294fd71e9cfb3e4855a4f",
            chainId: 56,
            rpcUrl: "https://bsc-dataseed4.ninicoin.io"
        ),
        TrustWeb3Provider.Config.EthereumConfig(
            address: "0x9d8a62f656a8d1615c1294fd71e9cfb3e4855a4f",
            chainId: 137,
            rpcUrl: "https://polygon-rpc.com"
        ),
        TrustWeb3Provider.Config.EthereumConfig(
            address: "0x9d8a62f656a8d1615c1294fd71e9cfb3e4855a4f",
            chainId: 250,
            rpcUrl: "https://rpc.ftm.tools"
        ),
        TrustWeb3Provider.Config.EthereumConfig(
            address: "0x9d8a62f656a8d1615c1294fd71e9cfb3e4855a4f",
            chainId: 42161,
            rpcUrl: "https://arb1.arbitrum.io/rpc"
        )
    ]
}


