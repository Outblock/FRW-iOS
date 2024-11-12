//
//  FlowAddressRegistor.swift
//  Flow Wallet
//
//  Created by Hao Fu on 26/6/2022.
//

import Flow
import Foundation

enum ScriptAddress: String, CaseIterable {
    case fungibleToken = "0xFungibleToken"
    case flowToken = "0xFlowToken"
    case flowFees = "0xFlowFees"
    case flowTablesTaking = "0xFlowTableStaking"
    case lockedTokens = "0xLockedTokens"
    case stakingProxy = "0xStakingProxy"
    case nonFungibleToken = "0xNonFungibleToken"
    case findToken = "0xFind"
    case domainsToken = "0xDomains"
    case flownsToken = "0xFlowns"
    case metadataViews = "0xMetadataViews"
    case swapRouter = "0xSwapRouter"
    case swapError = "0xSwapError"
    case stakingCollection = "0xStakingCollection"
    case flowIDTableStaking = "0xFlowIDTableStaking"
    case hybridCustody = "0xHybridCustody"
    case evm = "0xEVM"
    case flowEVMBridge = "0xFlowEVMBridge"
    case CapabilityFilter = "0xCapabilityFilter"

    // MARK: Internal

    static func addressMap(
        on network: LocalUserDefaults.FlowNetworkType = LocalUserDefaults.shared
            .flowNetwork
    ) -> [String: String] {
        let dict = ScriptAddress.allCases
            .reduce(into: [String: String]()) { partialResult, script in
                if let address = script.address(on: network) {
                    partialResult[script.rawValue] = address.hex.withPrefix()
                }
            }
        return dict
    }

    func address(
        on network: LocalUserDefaults.FlowNetworkType = LocalUserDefaults.shared
            .flowNetwork
    ) -> Flow.Address? {
        guard let addressMap = RemoteConfigManager.shared.getContarctAddress(network),
              let address = addressMap[rawValue], !address.isEmpty else {
            return nil
        }

        return Flow.Address(hex: address)
    }
}
