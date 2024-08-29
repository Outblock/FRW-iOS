//
//  TrustProvider.swift
//  FRW
//
//  Created by cat on 2024/3/4.
//

import Foundation
import WalletCore

extension TrustWeb3Provider {
    
    static func flowConfig() -> TrustWeb3Provider? {
        guard let address = EVMAccountManager.shared.accounts.first?.showAddress, let url = LocalUserDefaults.shared.flowNetwork.evmUrl?.absoluteString else {
            return nil
        }
        let chainId = LocalUserDefaults.shared.flowNetwork.networkID
        let config = TrustWeb3Provider.Config.EthereumConfig(address: address, chainId: chainId, rpcUrl: url)
        return TrustWeb3Provider(config: .init(ethereum: config))
    }
    
}


