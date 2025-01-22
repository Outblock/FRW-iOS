//
//  FlowNetworkType.swift
//  FRW
//
//  Created by Antonio Bello on 11/20/24.
//

import Foundation
import Flow
import struct SwiftUI.Color

enum FlowNetworkType: String, CaseIterable, Codable {
    case testnet
    case mainnet
    
    // MARK: Lifecycle
    
    init?(chainId: Flow.ChainID) {
        switch chainId {
        case .testnet:
            self = .testnet
        case .mainnet:
            self = .mainnet
        default:
            return nil
        }
    }
    
    // MARK: Internal
    
    var color: Color {
        switch self {
        case .mainnet:
            return Color.LL.Primary.salmonPrimary
        case .testnet:
            return Color(hex: "#FF8A00")
        }
    }
    
    var isMainnet: Bool {
        self == .mainnet
    }
    
    func toFlowType() -> Flow.ChainID {
        switch self {
        case .testnet:
            return Flow.ChainID.testnet
        case .mainnet:
            return Flow.ChainID.mainnet
        }
    }
}
