//
//  ChildAccountAccessibleManager.swift
//  Flow Wallet
//
//  Created by cat on 2023/8/8.
//

import Foundation


extension ChildAccountManager {
    struct AccessibleManager {
        
        private var parentAddr: String? {
            return WalletManager.shared.getPrimaryWalletAddress()
        }
        private var childAddr: String? {
            return WalletManager.shared.childAccount?.addr
        }
        
        var coins: [FlowModel.TokenInfo]?
        var collections: [FlowModel.NFTCollection]?
        
        mutating func fetchFT() async throws {
            
            guard let childAddr = self.childAddr, let parentAddr = self.parentAddr else {
                coins = []
                return
            }
            coins = try await FlowNetwork.fetchAccessibleFT(parent: parentAddr, child: childAddr)
        }
        
        mutating func fetchNFT() async throws {
            guard let childAddr = self.childAddr, let parentAddr = self.parentAddr else {
                collections = []
                return
            }
            collections = try await FlowNetwork.fetchAccessibleCollection(parent: parentAddr, child: childAddr)
        }
        
        
        func isChildAccount() -> Bool {
            if parentAddr != nil && childAddr != nil {
                return true
            }
            return false
        }
        // check coin
        func isAccessible(_ model: TokenModel) -> Bool {
            guard isChildAccount() else {
                return true
            }
            let result = coins?.filter({ info in

                guard let modelAddr = model.getAddress(),
                      let contractName = info.id.split(separator:".")[safe: 2],
                      let address = info.id.split(separator:".")[safe: 1] else {
                    return false
                }
                return contractName == model.contractName && address == modelAddr
                
            })
            return result?.count == 1
        }
        
        // check collection
        func isAccessible(_ model: NFTCollectionInfo) -> Bool {
            guard isChildAccount() else {
                return true
            }
            let result = collections?.filter({ fModel in
                guard let contractName = fModel.id.split(separator:".")[safe: 2],
                      let address = fModel.id.split(separator:".")[safe: 1] else {
                    return false
                }
                return contractName == model.contractName && address == model.address
            })
            return result?.count == 1
        }
        // check nft
        func isAccessible(_ model: NFTModel) ->Bool {
            guard isChildAccount() else {
                return true
            }
            let result = collections?.filter({ fModel in
                guard let contractName = fModel.id.split(separator:".")[safe: 2],
                      let address = fModel.id.split(separator:".")[safe: 1],
                      let targetName = model.collection?.contractName,
                      let targetAddr = model.collection?.address
                else {
                    return false
                }
                return contractName == targetName && address == targetAddr
            })
            //TODO: NFT 的id 
            guard let collection = result?.first, let targerId = UInt64(model.id) else {
                return false
            }
            
            return collection.idList.contains(targerId)
        }
    }
}
