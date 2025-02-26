//
//  FWAddress.swift
//  FRW
//
//  Created by Hao Fu on 24/2/2025.
//

import Foundation
import Web3Core
import Flow

enum VMType {
    case cadence
    case evm
    
    func toTokenType() -> TokenModel.TokenType {
        switch self {
        case .cadence:
            return .cadence
        case .evm:
            return .evm
        }
    }
}

protocol FWAddress {
    var type: VMType { get }
    var hexAddr: String { get }
}

struct FWAddressDector {
    static func create(address: String?) -> FWAddress? {
        guard let address, !address.isEmpty else {
            return nil
        }
        
        let hexAddr = address.addHexPrefix()
        
        if let ethAddr = EthereumAddress(hexAddr) {
            return ethAddr
        }
        
        return Flow.Address(hex: hexAddr.stripHexPrefix())
    }
}

extension Flow.Address: FWAddress {
    var type: VMType {
        .cadence
    }
    
    var hexAddr: String {
        hex
    }
}

extension EthereumAddress: FWAddress {
    var type: VMType {
        .evm
    }
    
    var hexAddr: String {
        address
    }
}
