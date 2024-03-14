//
//  NFTCollectionStateManager.swift
//  Flow Wallet
//
//  Created by cat on 2022/6/22.
//

import Foundation
import Flow

final class NFTCollectionStateManager {
    
    static let share = NFTCollectionStateManager()
    
    private init() {
        
    }

    private var tokenStateList: [NftCollectionState] = []

    func fetch() async {
        let list = NFTCollectionConfig.share.config
        guard let address = WalletManager.shared.walletInfo?.currentNetworkWalletModel?.getAddress,
                !address.isEmpty else {
            return
        }
        
        do {
            var tempList = list
            var finalList: [Bool] = []
            repeat {
                let pendingRequestList = Array(tempList.prefix(60))
                tempList = Array(tempList.dropFirst(60))
                let isEnableList = try await FlowNetwork.checkCollectionEnable(address: Flow.Address(hex: address), list: pendingRequestList);
                finalList.append(contentsOf: isEnableList)
            } while (tempList.count > 0)
            
            guard finalList.count == list.count else {
                debugPrint("NFTCollectionStateManager: finalList.count != list.count")
                return
            }
            
            for (index, collection) in list.enumerated() {
                let isEnable = finalList[index]
                if let oldIndex = tokenStateList.firstIndex(where: { $0.address == collection.address}) {
                    tokenStateList.remove(at: oldIndex)
                }
                tokenStateList.append(NftCollectionState(name: collection.name, address: collection.address, isAdded: isEnable))
            }
            
        }catch {
            debugPrint("NFTCollectionStateManager: \(error)")
        }
    }
    func isTokenAdded(_ address: String) -> Bool {
        tokenStateList.first { $0.address == address }?.isAdded ?? false
    }
    

}

struct NftCollectionState {
    var name: String
    var address: String
    var isAdded: Bool
}
