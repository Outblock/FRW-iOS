//
//  NetworkProvider.swift
//  FRW
//
//  Created by cat on 2024/5/16.
//

import Foundation

extension LocalUserDefaults.FlowNetworkType {
    var networkID: Int {
        switch self {
        case .testnet:
            return 0
        case .mainnet:
            return 747
        case .crescendo:
            return 0
        case .previewnet:
            return 646
        }
    }
    
    var evmUrl: URL? {
        switch self {
        case .testnet:
            return URL(string: "https://testnet.evm.nodes.onflow.org")
        case .mainnet:
            return URL(string: "https://mainnet.evm.nodes.onflow.org")
        case .crescendo:
            return nil
        case .previewnet:
            return URL(string: "https://previewnet.evm.nodes.onflow.org")
        }
    }
}