//
//  CadenceManager.swift
//  FRW
//
//  Created by cat on 2024/3/2.
//

import SwiftUI

class CadenceManager {
    
    static let shared = CadenceManager()

    var scripts: CadenceScript!
    
    var current: CadenceModel {
        switch LocalUserDefaults.shared.flowNetwork {
        case .testnet:
            return scripts.testnet
        case .mainnet:
            return scripts.mainnet
        case .crescendo:
            return scripts.crescendo
        }
    }
    
    private init(){
        do {
            guard let filePath = Bundle.main.path(forResource: "cloudfunctions", ofType: "json") else {
                log.error("CadenceManager -> loadFromLocalFile error: no local file")
                return
            }
            
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            let providers = try JSONDecoder().decode(CadenceResponse.self, from: data)
            self.scripts = providers.scripts
        }
        catch {
            log.error("CadenceManager -> decode failer: \(error)")
        }
        fetchScript()
    }
    
    private func fetchScript() {
        Task {
            do {
                let response: CadenceResponse = try await Network.requestWithRawModel(FRWAPI.Cadence.list)
                DispatchQueue.main.async {
                    self.scripts = response.scripts
                }
            }
            catch {
                log.error("CadenceManager -> fetch failed: \(error)")
            }
        }
    }
}

struct CadenceResponse: Codable {
    let scripts: CadenceScript
}

struct CadenceScript: Codable {
    let testnet: CadenceModel
    let crescendo: CadenceModel
    let mainnet: CadenceModel
}

struct CadenceModel: Codable {
    let version: String
    let basic: CadenceModel.Basic
    let account: CadenceModel.Account
    let collection: CadenceModel.Collection
    let contract: CadenceModel.Contract
    let domain: CadenceModel.Domain
    let ft: CadenceModel.FlowToken
    
    let hybridCustody: CadenceModel.HybridCustody
    let staking: CadenceModel.Staking
    let storage: CadenceModel.Storage
    let switchboard: CadenceModel.Switchboard
    let nft: CadenceModel.NFT
    let swap: CadenceModel.Swap
}

extension CadenceModel {
    struct Basic: Codable {
        let addKey: String
        let getAccountInfo: String
        let getFindAddress: String
        let getFindDomainByAddress: String
        let getFlownsAddress: String
        let getFlownsDomainsByAddress: String
        let getStorageInfo: String
        let getTokenBalanceWithModel: String
        let isTokenStorageEnabled: String
        let revokeKey: String
    }
    
    struct Account: Codable {
        let getBookmark: String
        let getBookmarks: String
    }
    
    struct Collection: Codable {
        let enableNFTStorage: String
        let getCatalogTypeData: String
        let getNFT: String
        let getNFTCatalogByCollectionIds: String
        let getNFTCollection: String
        let getNFTDisplays: String
        let getNFTMetadataViews: String
        let sendNbaNFT: String
        let sendNFT: String
        
        let enableNFTStorageTest: String?
        let getNFTCollectionTest: String?
        let getNFTDisplaysTest: String?
        let getNFTMetadataViewsTest: String?
        let getNFTTest: String?
        let sendNFTTest: String?
        
    }
    
    struct Contract: Codable {
        let getContractNames: String
        let getContractByName: String
    }
    
    struct Domain: Codable {
        let claimFTFromInbox: String
        let claimNFTFromInbox: String
        let getAddressOfDomain: String
        let getDefaultDomainsOfAddress: String
        let getFlownsInbox: String
        let sendInboxNFT: String
        let transferInboxTokens: String
    }
    
    struct FlowToken: Codable {
        let addToken: String
        let enableTokenStorage: String
        let transferTokens: String
        
        let isTokenListEnabled: String
        let getTokenListBalance: String
    }
    
    struct HybridCustody: Codable {
        let editChildAccount: String
        let getAccessibleCoinInfo: String
        let getAccessibleCollectionAndIds: String
        let getAccessibleCollectionAndIdsDisplay: String
        let getAccessibleCollectionsAndIds: String
        
        
        let getAccessibleFungibleToken: String
        let getChildAccount: String
        let getChildAccountMeta: String
        let getChildAccountNFT: String
        let unlinkChildAccount: String
    }
    
    struct Staking: Codable {
        let checkSetup: String
        
        let createDelegator: String
        let createStake: String
        let getApr: String
        let getDelegatesIndo: String
        let getDelegatorInfo: String
        let getEpochMetadata: String
        let getNodeInfo: String
        let getNodesInfo: String
        
        let getDelegatesInfoArray: String
        let getApyWeekly: String
        
        let getStakeInfo: String
        let getStakingInfo: String
        let restakeReward: String
        let restakeUnstaked: String
        

        let setup: String
        let unstake: String
        let withdrawLocked: String
        let withdrawReward: String
        let withdrawUnstaked: String
    }
    
    struct Storage: Codable {
        let enableTokenStorage: String
        let getBasicPublicItems: String
        let getPrivateItems: String
        let getPrivatePaths: String
        let getPublicItem: String
        let getPublicItems: String
        let getPublicPaths: String
        let getStoragePaths: String
        let getStoredItems: String
        let getStoredResource: String
        let getStoredStruct: String
        
        let getBasicPublicItemsTest: String
        let getPrivateItemsTest: String
    }
    
    struct Switchboard: Codable {
        let getSwitchboard: String
    }
    
    struct NFT: Codable {
        let checkNFTListEnabledNew: String
        let checkNFTListEnabled: String
    }
    
    struct Swap: Codable {
        let DeployPairTemplate: String
        let CreatePairTemplate: String
        let AddLiquidity: String
        let RemoveLiquidity: String
        let SwapExactTokensForTokens: String
        let SwapTokensForExactTokens: String
        let MintAllTokens: String
        let QueryTokenNames: String
        
        let QueryPairArrayAddr: String
        let QueryPairArrayInfo: String
        let QueryPairInfoByAddrs: String
        let QueryPairInfoByTokenKey: String
        let QueryUserAllLiquidities: String
        let QueryTimestamp: String
        
        let QueryVaultBalanceBatched: String
        let QueryTokenPathPrefix: String
        let CenterTokens: [String]?
    }
}

extension String {
    public func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    public func toFunc() -> String {
        guard let result = self.fromBase64() else {
            log.error("[Cadence] base decode failed")
            return ""
        }
        return result
    }
}