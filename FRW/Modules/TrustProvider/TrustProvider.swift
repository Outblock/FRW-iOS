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
        let hdWallet = HDWallet(strength: WalletManager.mnemonicStrength, passphrase: "")
        let address = hdWallet!.getAddressForCoin(coin: .ethereum)
        let config = TrustWeb3Provider.Config.EthereumConfig(address: address, chainId: 1, rpcUrl: "https://cloudflare-eth.com")
        return TrustWeb3Provider(config: .init(ethereum: config))
    }
    
}


