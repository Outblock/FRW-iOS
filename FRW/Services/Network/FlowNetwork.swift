//
//  FlowNetwork.swift
//  Flow Wallet
//
//  Created by Hao Fu on 30/4/2022.
//

import BigInt
import Combine
import Flow
import Foundation
import Web3Core

enum FlowNetwork {
    static func setup() {
        let type = LocalUserDefaults.shared.flowNetwork.toFlowType()
        log.debug("did setup flow chainID to \(LocalUserDefaults.shared.flowNetwork.rawValue)")
        flow.configure(chainID: type)
    }
}

// MARK: - Token

extension FlowNetwork {
    
    static func checkTokensEnable(address: Flow.Address) async throws -> [String: Bool] {
        let cadence = CadenceManager.shared.current.ft?.isTokenListEnabled?.toFunc() ?? ""
        return try await fetch(at: address, by: cadence)
    }
    
    static func fetchBalance(at address: Flow.Address) async throws -> [String: Double] {
        let cadence = CadenceManager.shared.current.ft?.getTokenListBalance?.toFunc() ?? ""
        return try await fetch(at: address, by: cadence)
    }
    
    static func enableToken(at address: Flow.Address, token: TokenModel) async throws -> Flow.ID {

        let originCadence = CadenceManager.shared.current.ft?.addToken?.toFunc() ?? ""
        let cadenceString = token.formatCadence(cadence: originCadence)
        let fromKeyIndex = WalletManager.shared.keyIndex

        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: address, keyIndex: fromKeyIndex)
            }
            
            authorizers {
                address
            }
            
            gasLimit {
                9999
            }
        }
    }
    
    static func transferToken(to address: Flow.Address, amount: Decimal, token: TokenModel) async throws -> Flow.ID {
        let cadenceString = TokenCadence.tokenTransfer(token: token, at: flow.chainID)
        let currentAdd = WalletManager.shared.getPrimaryWalletAddress() ?? ""
        let keyIndex = WalletManager.shared.keyIndex
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: Flow.Address(hex: currentAdd), keyIndex: keyIndex)
                
            }
            
            authorizers {
                Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
            }
            
            arguments {
                [.ufix64(amount), .address(address)]
            }
            
            gasLimit {
                9999
            }
        })
    }
    
    static func minFlowBalance() async throws -> Double {
        guard let fromAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        let cadenceString = CadenceManager.shared.current.basic?.getAccountMinFlow?.toFunc() ?? ""
        let result: Decimal = try await fetch(cadence: cadenceString, arguments: [.address(Flow.Address(hex: fromAddress))])
        return result.doubleValue
    }
}

// MARK: - NFT

extension FlowNetwork {
    static func checkCollectionEnable(address: Flow.Address, list: [NFTCollectionInfo]) async throws -> [Bool] {
        //TODO: #six
        let cadence = NFTCadence.collectionListCheckEnabled(with: list, on: flow.chainID)
        return try await fetch(at: address, by: cadence)
    }
    
    static func addCollection(at address: Flow.Address, collection: NFTCollectionInfo) async throws -> Flow.ID {
        let originCadence = CadenceManager.shared.current.collection?.enableNFTStorage?.toFunc() ?? ""
        let cadenceString = collection.formatCadence(script: originCadence)
        let fromKeyIndex = WalletManager.shared.keyIndex
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: address, keyIndex: fromKeyIndex)
            }
            
            authorizers {
                address
            }
            
            gasLimit {
                9999
            }
        })
    }
    
    static func transferNFT(to address: Flow.Address, nft: NFTModel) async throws -> Flow.ID {
        guard let collection = nft.collection else {
            throw NFTError.noCollectionInfo
        }
        
        guard let fromAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        
        guard let tokenIdInt = UInt64(nft.response.id) else {
            throw NFTError.invalidTokenId
        }
        
        let nftTransfer = CadenceManager.shared.current.domain?.sendInboxNFT?.toFunc() ?? ""
        let nbaNFTTransfer = CadenceManager.shared.current.collection?.sendNbaNFT?.toFunc() ?? ""
        let cadenceString = collection.formatCadence(script: nft.isNBA ? nbaNFTTransfer : nftTransfer)
        let fromKeyIndex = WalletManager.shared.keyIndex
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                
                Flow.TransactionProposalKey(address: Flow.Address(hex: fromAddress), keyIndex: fromKeyIndex)

            }
            
            authorizers {
                Flow.Address(hex: fromAddress)
            }
            
            arguments {
                [.address(address), .uint64(tokenIdInt)]
            }
            
            gasLimit {
                9999
            }
        })
    }
}

// MARK: - Search

extension FlowNetwork {
    static func queryAddressByDomainFind(domain: String) async throws -> String {
        let cadence = CadenceManager.shared.current.basic?.getFindAddress?.toFunc() ?? ""
        return try await fetch(cadence: cadence, arguments: [.string(domain)])
    }
    
    static func queryAddressByDomainFlowns(domain: String, root: String = "fn") async throws -> String {
        let cadence = CadenceManager.shared.current.basic?.getFlownsAddress?.toFunc() ?? ""
        
        let realDomain = domain
            .replacingOccurrences(of: ".fn", with: "")
            .replacingOccurrences(of: ".meow", with: "")
        return try await fetch(cadence: cadence, arguments: [.string(realDomain), .string(root)])
    }
}

// MARK: - Inbox

extension FlowNetwork {
    static func claimInboxToken(domain: String, key: String, coin: TokenModel, amount: Decimal, root: String = Contact.DomainType.meow.domain) async throws -> Flow.ID {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        let cadenceString = coin.formatCadence(cadence: CadenceManager.shared.current.domain?.claimFTFromInbox?.toFunc() ?? "")
        let fromKeyIndex = WalletManager.shared.keyIndex
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                
                Flow.TransactionProposalKey(address: Flow.Address(hex: address), keyIndex: fromKeyIndex)

            }
            
            authorizers {
                Flow.Address(hex: address)
            }
            
            arguments {
                [.string(domain), .string(root), .string(key), .ufix64(amount)]
            }
            
            gasLimit {
                9999
            }
        })
    }
    
    static func claimInboxNFT(domain: String, key: String, collection: NFTCollectionInfo, itemId: UInt64, root: String = Contact.DomainType.meow.domain) async throws -> Flow.ID {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        let cadenceString = collection.formatCadence(script: CadenceManager.shared.current.domain?.claimNFTFromInbox?.toFunc() ?? "")
        let fromKeyIndex = WalletManager.shared.keyIndex
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: Flow.Address(hex: address), keyIndex: fromKeyIndex)
            }
            
            authorizers {
                Flow.Address(hex: address)
            }
            
            arguments {
                [.string(domain), .string(root), .string(key), .uint64(itemId)]
            }
            
            gasLimit {
                9999
            }
        })
    }
}

// MARK: - Swap

extension FlowNetwork {
    static func swapToken(swapPaths: [String], tokenInMax: Decimal, tokenOutMin: Decimal, tokenInVaultPath: String, tokenOutSplit: [Decimal], tokenInSplit: [Decimal], tokenOutVaultPath: String, tokenOutReceiverPath: String, tokenOutBalancePath: String, deadline: Decimal, isFrom: Bool) async throws -> Flow.ID {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        
        let tokenName = String(swapPaths.last?.split(separator: ".").last ?? "")
        let tokenAddress = String(swapPaths.last?.split(separator: ".")[1] ?? "").addHexPrefix()
        
        let fromCadence = CadenceManager.shared.current.swap?.SwapExactTokensForTokens?.toFunc() ?? ""
        let toCadence = CadenceManager.shared.current.swap?.SwapTokensForExactTokens?.toFunc() ?? ""
        var cadenceString = isFrom ? fromCadence : toCadence
        cadenceString = cadenceString
            .replace(by: ["Token1Name": tokenName, "Token1Addr": tokenAddress])
            .replace(by: ScriptAddress.addressMap())
        log.error("[Cadence] swap from:\n \(cadenceString)")
        var args = [Flow.Cadence.FValue]()
        args.append(.array(swapPaths.map { .string($0) }))
        
        if isFrom {
            args.append(.array(tokenInSplit.map { .ufix64($0) }))
            args.append(.ufix64(tokenOutMin))
        } else {
            args.append(.array(tokenOutSplit.map { .ufix64($0) }))
            args.append(.ufix64(tokenInMax))
        }
        
        args.append(.ufix64(deadline))
        args.append(.path(Flow.Argument.Path(domain: "storage", identifier: tokenInVaultPath)))
        args.append(.path(Flow.Argument.Path(domain: "storage", identifier: tokenOutVaultPath)))
        args.append(.path(Flow.Argument.Path(domain: "public", identifier: tokenOutReceiverPath)))
        args.append(.path(Flow.Argument.Path(domain: "public", identifier: tokenOutBalancePath)))
        let fromKeyIndex = WalletManager.shared.keyIndex
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: Flow.Address(hex: address), keyIndex: fromKeyIndex)
            }
            
            authorizers {
                Flow.Address(hex: address)
            }
            
            arguments {
                args
            }
            
            gasLimit {
                9999
            }
        })
    }
}

// MARK: - Stake

enum LilicoError: Error {
    case emptyWallet
}

extension FlowNetwork {
    static func stakingIsEnabled() async throws -> Bool {
        let cadence = CadenceManager.shared.current.staking?.checkSetup?.toFunc() ?? ""
        let address = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        return try await self.fetch(cadence: cadence, arguments: [.address(address)])
    }
    
    static func accountStakingIsSetup() async throws -> Bool {
        let cadence = CadenceManager.shared.current.staking?.checkSetup?.toFunc() ?? ""
        let address = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        return try await self.fetch(cadence: cadence, arguments: [.address(address)])
    }
    
    static func claimUnstake(nodeID: String, delegatorId: Int, amount: Decimal) async throws -> Flow.ID {
        guard let walletAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LilicoError.emptyWallet
        }
        
        let address = Flow.Address(hex: walletAddress)
        let cadenceOrigin = CadenceManager.shared.current.staking?.withdrawUnstaked?.toFunc() ?? ""
        let fromKeyIndex = WalletManager.shared.keyIndex
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                cadenceOrigin.replace(by: ScriptAddress.addressMap())
            }
            
            arguments {
                [.string(nodeID), .uint32(UInt32(delegatorId)), .ufix64(amount)]
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: address, keyIndex: fromKeyIndex)
            }
            
            authorizers {
                address
            }
        }
    }
    
    static func reStakeUnstake(nodeID: String, delegatorId: Int, amount: Decimal) async throws -> Flow.ID {
        guard let walletAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LilicoError.emptyWallet
        }
        
        let address = Flow.Address(hex: walletAddress)
        let cadenceOrigin = CadenceManager.shared.current.staking?.restakeUnstaked?.toFunc() ?? ""
        let fromKeyIndex = WalletManager.shared.keyIndex
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                cadenceOrigin.replace(by: ScriptAddress.addressMap())
            }
            
            arguments {
                [.string(nodeID), .uint32(UInt32(delegatorId)), .ufix64(amount)]
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: address, keyIndex: fromKeyIndex)
            }
            
            authorizers {
                address
            }
        }
    }
    
    static func claimReward(nodeID: String, delegatorId: Int, amount: Decimal) async throws -> Flow.ID {
        guard let walletAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LilicoError.emptyWallet
        }
        
        let address = Flow.Address(hex: walletAddress)
        let cadenceOrigin = CadenceManager.shared.current.staking?.withdrawReward?.toFunc() ?? ""
        let fromKeyIndex = WalletManager.shared.keyIndex
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                cadenceOrigin.replace(by: ScriptAddress.addressMap())
            }
            
            arguments {
                [.string(nodeID), .uint32(UInt32(delegatorId)), .ufix64(amount)]
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: address, keyIndex: fromKeyIndex)
            }
            
            authorizers {
                address
            }
        }
    }
    
    static func reStakeReward(nodeID: String, delegatorId: Int, amount: Decimal) async throws -> Flow.ID {
        guard let walletAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LilicoError.emptyWallet
        }
        
        let address = Flow.Address(hex: walletAddress)
        let cadenceOrigin = CadenceManager.shared.current.staking?.restakeReward?.toFunc() ?? ""
        let fromKeyIndex = WalletManager.shared.keyIndex
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                cadenceOrigin.replace(by: ScriptAddress.addressMap())
            }
            
            arguments {
                [.string(nodeID), .uint32(UInt32(delegatorId)), .ufix64(amount)]
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: address, keyIndex: fromKeyIndex)
            }
            
            authorizers {
                address
            }
        }
    }
    
    static func setupAccountStaking() async throws -> Bool {
        let cadenceOrigin = CadenceManager.shared.current.staking?.setup?.toFunc() ?? ""
        let cadenceString = cadenceOrigin.replace(by: ScriptAddress.addressMap())
        
        guard let walletAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LilicoError.emptyWallet
        }
        let address = Flow.Address(hex: walletAddress)
        let fromKeyIndex = WalletManager.shared.keyIndex
        let txId = try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: address, keyIndex: fromKeyIndex)
            }
            
            authorizers {
                address
            }
        })
        
        let result = try await txId.onceSealed()
        
        if result.isFailed {
            debugPrint("FlowNetwork: setupAccountStaking failed msg: \(result.errorMessage)")
            return false
        }
        
        return true
    }
    
    static func createDelegatorId(providerId: String, amount: Double = 0) async throws -> Flow.ID {
        let cadenceOrigin = CadenceManager.shared.current.staking?.createDelegator?.toFunc() ?? ""
        let cadenceString = cadenceOrigin.replace(by: ScriptAddress.addressMap())
        let address = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        let fromKeyIndex = WalletManager.shared.keyIndex
        let txId = try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: address, keyIndex: fromKeyIndex)
            }
            
            authorizers {
                address
            }
            
            arguments {
                [.string(providerId), .ufix64(Decimal(amount))]
            }
            
            gasLimit {
                9999
            }
        })
        return txId
    }
    
    static func stakeFlow(providerId: String, delegatorId: Int, amount: Double) async throws -> Flow.ID {
        let cadenceOrigin = CadenceManager.shared.current.staking?.createStake?.toFunc() ?? ""
        let cadenceString = cadenceOrigin.replace(by: ScriptAddress.addressMap())
        let address = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        let fromKeyIndex = WalletManager.shared.keyIndex
        let txId = try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: address, keyIndex: fromKeyIndex)
            }
            
            authorizers {
                address
            }
            
            arguments {
                [.string(providerId), .uint32(UInt32(delegatorId)), .ufix64(Decimal(amount))]
            }
            
            gasLimit {
                9999
            }
        })
        
        return txId
    }
    
    static func unstakeFlow(providerId: String, delegatorId: Int, amount: Double) async throws -> Flow.ID {
        let cadenceOrigin = CadenceManager.shared.current.staking?.unstake?.toFunc() ?? ""
        let cadenceString = cadenceOrigin.replace(by: ScriptAddress.addressMap())
        let address = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        let fromKeyIndex = WalletManager.shared.keyIndex
        let txId = try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: address, keyIndex: fromKeyIndex)
            }
            
            authorizers {
                address
            }
            
            arguments {
                [.string(providerId), .uint32(UInt32(delegatorId)), .ufix64(Decimal(amount))]
            }
            
            gasLimit {
                9999
            }
        })
        
        return txId
    }
    
    static func queryStakeInfo() async throws -> [StakingNode]? {
        let address = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        let cadence = CadenceManager.shared.current.staking?.getDelegatesInfoArray?.toFunc() ?? ""
        let response: [StakingNode] = try await self.fetch(at: address, by: cadence)
        debugPrint("FlowNetwork -> queryStakeInfo, response = \(response)")
        return response
    }
    
    static func getStakingApyByWeek() async throws -> Double {
        let candence = CadenceManager.shared.current.staking?.getApyWeekly?.toFunc() ?? ""
        let result: Decimal = try await fetch(cadence: candence, arguments: [])
        
        return result.doubleValue
    }
    
    static func getStakingApyByYear() async throws -> Double {
        let candence = CadenceManager.shared.current.staking?.getApr?.toFunc() ?? ""
        let result: Decimal = try await fetch(cadence: candence, arguments: [])

        return result.doubleValue
    }
    
    static func getDelegatorInfo() async throws -> [String: Int]? {
        let address = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        let cadence = CadenceManager.shared.current.staking?.getDelegatesIndo?.toFunc() ?? ""
        let replacedCadence = cadence.replace(by: ScriptAddress.addressMap())
        let rawResponse = try await flow.accessAPI.executeScriptAtLatestBlock(script: Flow.Script(text: replacedCadence),
                                                                              arguments: [.address(address)])
        
        let response = try JSONDecoder().decode(StakingDelegatorInner.self, from: rawResponse.data)
        debugPrint("FlowNetwork -> getDelegatorInfo, response = \(response)")
        
        guard let values = response.value?.value else {
            return nil
        }

        let compactValues = values.compactMap { $0 }

        var results: [String: Int] = [:]
        for value in compactValues {
            if let resultKey = value.key?.value {
                let resultValue = Int(value.value?.value?.first??.key?.value ?? "0") ?? 0
                results[resultKey] = resultValue
            }
        }

        return results
    }
}

// MARK: - Child Account

extension FlowNetwork {
    static func queryChildAccountList() async throws -> [String] {
        let address = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        let cadence = CadenceManager.shared.current.hybridCustody?.getChildAccount?.toFunc() ?? ""
        let response: [String] = try await self.fetch(at: address, by: cadence)
        return response
    }
    
    static func unlinkChildAccount(_ address: String) async throws -> Flow.ID {
        let cadenceOrigin = CadenceManager.shared.current.hybridCustody?.unlinkChildAccount?.toFunc() ?? ""
        let cadenceString = cadenceOrigin.replace(by: ScriptAddress.addressMap())
        let walletAddress = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        let fromKeyIndex = WalletManager.shared.keyIndex
        let txId = try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: walletAddress, keyIndex: fromKeyIndex)
            }
            
            authorizers {
                walletAddress
            }
            
            arguments {
                [.address(Flow.Address(hex: address))]
            }
            
            gasLimit {
                9999
            }
        })
        
        return txId
    }
    
    static func queryChildAccountMeta(_ address: String) async throws -> [ChildAccount] {
        let address = Flow.Address(hex: address)
        let cadence = CadenceManager.shared.current.hybridCustody?.getChildAccountMeta?.toFunc() ?? ""
        let replacedCadence = cadence.replace(by: ScriptAddress.addressMap())
        let rawResponse = try await flow.accessAPI.executeScriptAtLatestBlock(script: Flow.Script(text: replacedCadence),
                                                                              arguments: [.address(address)])

        guard let decode = rawResponse.decode() as? [String: Any?] else {
            return []
        }

        let result: [ChildAccount] = decode.keys.compactMap { key in
            guard let value = decode[key],
                  let value = value,
                  let data = try? JSONSerialization.data(withJSONObject: value),
                  var model = try? JSONDecoder().decode(ChildAccount.self, from: data)
            else {
                return ChildAccount(address: key, name: nil, desc: nil, icon: nil, pinTime: 0)
            }
            
            model.addr = key
            return model
        }

        return result
    }
    
    static func editChildAccountMeta(_ address: String, name: String, desc: String, thumbnail: String) async throws -> Flow.ID {
        let editChildAccount = CadenceManager.shared.current.hybridCustody?.editChildAccount?.toFunc() ?? ""
        let cadenceString = editChildAccount.replace(by: ScriptAddress.addressMap())
        let walletAddress = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        let fromKeyIndex = WalletManager.shared.keyIndex
        let txId = try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: walletAddress, keyIndex: fromKeyIndex)
            }
            
            authorizers {
                walletAddress
            }
            
            arguments {
                [.address(Flow.Address(hex: address)), .string(name), .string(desc), .string(thumbnail)]
            }
            
            gasLimit {
                9999
            }
        })
        
        return txId
    }
    
    static func fetchAccessibleCollection(parent: String, child: String) async throws -> [FlowModel.NFTCollection] {
        let cadence = CadenceManager.shared.current.hybridCustody?.getAccessibleCollectionAndIdsDisplay?.toFunc() ?? ""
        let cadenceString = cadence.replace(by: ScriptAddress.addressMap())
        let parentAddress = Flow.Address(hex: parent)
        let childAddress = Flow.Address(hex: child)
        let response = try await flow.accessAPI
            .executeScriptAtLatestBlock(script: Flow.Script(text: cadenceString), arguments: [.address(parentAddress), .address(childAddress)])
            .decode([FlowModel.NFTCollection].self)
        return response
    }
    
    static func fetchAccessibleFT(parent: String, child: String) async throws -> [FlowModel.TokenInfo] {
        let accessible = CadenceManager.shared.current.hybridCustody?.getAccessibleCoinInfo?.toFunc() ?? ""
        let cadenceString = accessible.replace(by: ScriptAddress.addressMap())
        let parentAddress = Flow.Address(hex: parent)
        let childAddress = Flow.Address(hex: child)
        let response = try await flow.accessAPI
            .executeScriptAtLatestBlock(script: Flow.Script(text: cadenceString), arguments: [.address(parentAddress), .address(childAddress)])
            .decode([FlowModel.TokenInfo].self)
        return response
    }
}

// MARK: - Others

extension FlowNetwork {
    static func addressVerify(address: String) async -> Bool {
        // testnet test address: 0x912d5440f7e3769e
        guard address.hasPrefix("0x") else {
            return false
        }

        let fAddress = Flow.Address(hex: address)
        do {
            _ = try await flow.accessAPI.getAccountAtLatestBlock(address: fAddress)
            return true
        } catch {
            return false
        }
    }
    
    static func getTransactionResult(by id: String) async throws -> Flow.TransactionResult {
        let idObj = Flow.ID(hex: id)
        return try await flow.accessAPI.getTransactionResultById(id: idObj)
    }
    
    static func getAccountAtLatestBlock(address: String) async throws -> Flow.Account {
        return try await flow.accessAPI.getAccountAtLatestBlock(address: Flow.Address(hex: address))
    }
    
    static func getLastBlockAccountKeyId(address: String) async throws -> Int {
        let account = try await getAccountAtLatestBlock(address: address)
        return account.keys.first?.index ?? 0
    }
    
    static func checkStorageInfo() async throws -> Flow.StorageInfo {
        let address = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        let cadence = CadenceManager.shared.current.basic?.getStorageInfo?.toFunc() ?? ""
        let response = try await flow.accessAPI.executeScriptAtLatestBlock(cadence: cadence, arguments: [.address(address)]).decode(Flow.StorageInfo.self)
        return response
    }
}

// MARK: - Base

extension FlowNetwork {
    private static func fetch<T: Decodable>(at address: Flow.Address, by cadence: String) async throws -> T {
        let replacedCadence = cadence.replace(by: ScriptAddress.addressMap())
        
        let response = try await flow.accessAPI.executeScriptAtLatestBlock(script: Flow.Script(text: replacedCadence),
                                                                           arguments: [.address(address)])
        let model: T = try response.decode()
        return model
    }
    
    private static func fetch<T: Decodable>(cadence: String, arguments: [Flow.Cadence.FValue]) async throws -> T {
        let replacedCadence = cadence.replace(by: ScriptAddress.addressMap())
        
        let response = try await flow.accessAPI.executeScriptAtLatestBlock(script: Flow.Script(text: replacedCadence), arguments: arguments)
        let model: T = try response.decode()
        return model
    }
}

// MARK: - Extension

extension Flow.TransactionResult {
    var isProcessing: Bool {
        status < .sealed && errorMessage.isEmpty
    }
    
    var isComplete: Bool {
        status == .sealed && errorMessage.isEmpty
    }
    
    var isExpired: Bool {
        status == .expired
    }
    
    var isFailed: Bool {
        if self.isProcessing {
            return false
        }
        
        if self.isExpired {
            return true
        }
        return !errorMessage.isEmpty
    }
}

// MARK: - Account Key

extension FlowNetwork {
    static func revokeAccountKey(by index: Int, at address: Flow.Address) async throws -> Flow.ID {
        let fromKeyIndex = WalletManager.shared.keyIndex
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                CadenceManager.shared.current.basic?.revokeKey?.toFunc() ?? ""
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: address, keyIndex: fromKeyIndex)
            }
            
            authorizers {
                address
            }
            
            arguments {
                [.int(index)]
            }
        })
    }
    
    static func addKeyToAccount(address: Flow.Address, accountKey: Flow.AccountKey, signers: [FlowSigner]) async throws -> Flow.ID {
        let originCadence = CadenceManager.shared.current.basic?.addKey?.toFunc() ?? ""
        let fromKeyIndex = WalletManager.shared.keyIndex
        return try await flow.sendTransaction(signers: signers) {
            cadence {
                originCadence
            }
            arguments {
                [
                    .string(accountKey.publicKey.hex),
                    .uint8(UInt8(accountKey.signAlgo.index)),
                    .uint8(UInt8(accountKey.hashAlgo.code)),
                    .ufix64(Decimal(accountKey.weight)),
                ]
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: address, keyIndex: fromKeyIndex)
            }
            authorizers {
                address
            }
        }
    }
    
    static func addKeyWithMulti(address: Flow.Address, keyIndex: Int, sequenceNum: Int64, accountKey: Flow.AccountKey, signers: [FlowSigner]) async throws -> Flow.ID {
        let originCadence = CadenceManager.shared.current.basic?.addKey?.toFunc() ?? ""
        return try await flow.sendTransaction(signers: signers) {
            cadence {
                originCadence
            }
            arguments {
                [
                    .string(accountKey.publicKey.hex),
                    .uint8(UInt8(accountKey.signAlgo.index)),
                    .uint8(UInt8(accountKey.hashAlgo.code)),
                    .ufix64(Decimal(accountKey.weight)),
                ]
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: address, keyIndex: keyIndex, sequenceNumber: sequenceNum)
            }
            authorizers {
                address
            }
        }
    }
}

// MARK: - EVM

extension FlowNetwork {
    static func createEVM() async throws -> Flow.ID {
        guard let fromAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        let originCadence = CadenceManager.shared.current.evm?.createCoaEmpty?.toFunc() ?? ""
        let cadenceStr = originCadence.replace(by: ScriptAddress.addressMap())
        let fromKeyIndex = WalletManager.shared.keyIndex

        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                cadenceStr
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.TransactionProposalKey(address: Flow.Address(hex: fromAddress), keyIndex: fromKeyIndex)
            }
            
            authorizers {
                Flow.Address(hex: fromAddress)
            }
            
            gasLimit {
                9999
            }
        }
    }
    
    static func findEVMAddress() async throws -> String {
        guard let fromAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        let  originCadence = CadenceManager.shared.current.evm?.getCoaAddr?.toFunc() ?? ""
        let cadenceStr = originCadence.replace(by: ScriptAddress.addressMap())
        let resonpse = try await flow.accessAPI.executeScriptAtLatestBlock(script: Flow.Script(text: cadenceStr), arguments: [.address(Flow.Address(hex: fromAddress))]).decode(String.self)
        return resonpse
    }
    
    static func fetchEVMBalance(address: String) async throws -> Decimal {
        guard let fromAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        let originCadence = CadenceManager.shared.current.evm?.getCoaBalance?.toFunc() ?? ""
        let cadenceStr = originCadence.replace(by: ScriptAddress.addressMap())
        
        let resonpse = try await flow.accessAPI.executeScriptAtLatestBlock(script: Flow.Script(text: cadenceStr), arguments: [.address(Flow.Address(hex: fromAddress))])
         let result =  try resonpse.decode(Decimal.self)
        return result
    }
    
    /// evm to cadence
    static func withdrawCoa(amount: Decimal) async throws -> Flow.ID {
        guard let toAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        let originCadence = CadenceManager.shared.current.evm?.withdrawCoa?.toFunc() ?? ""
        let cadenceStr = originCadence.replace(by: ScriptAddress.addressMap())
        let toKeyIndex = WalletManager.shared.keyIndex
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                cadenceStr
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            arguments {
                [
                    .ufix64(amount),
                    .address(Flow.Address(hex: toAddress))
                ]
            }
            proposer {
                Flow.TransactionProposalKey(address: Flow.Address(hex: toAddress), keyIndex: toKeyIndex)
            }
            
            authorizers {
                Flow.Address(hex: toAddress)
            }
            
            gasLimit {
                9999
            }
        }
    }
    /// cadence to evm
    static func fundCoa(amount: Decimal) async throws -> Flow.ID {
        guard let toAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        let originCadence = CadenceManager.shared.current.evm?.fundCoa?.toFunc() ?? ""
        let cadenceStr = originCadence.replace(by: ScriptAddress.addressMap())
        let toKeyIndex = WalletManager.shared.keyIndex
        
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                cadenceStr
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            arguments {
                [
                    .ufix64(amount),
                ]
            }
            proposer {
                Flow.TransactionProposalKey(address: Flow.Address(hex: toAddress), keyIndex: toKeyIndex)
            }
            
            authorizers {
                Flow.Address(hex: toAddress)
            }
            
            gasLimit {
                9999
            }
        }
    }
    
    static func sendTransaction(amount: String, data: Data?, toAddress: String, gas: UInt64) async throws -> Flow.ID {
        
        guard let amountParse = Decimal(string: amount) else {
            throw WalletError.insufficientBalance
        }
        let originCadence = CadenceManager.shared.current.evm?.callContract?.toFunc() ?? ""
        let cadenceStr = originCadence.replace(by: ScriptAddress.addressMap())
        let toKeyIndex = WalletManager.shared.keyIndex
        
        guard let fromAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        var argData: Flow.Cadence.FValue =  .array([])
        if let toValue = data?.cadenceValue {
            argData = toValue
        }
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                cadenceStr
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            arguments {
                [
                    .string(toAddress),
                    .ufix64(amountParse),
                    argData,
                    .uint64(gas)
                ]
            }
            proposer {
                Flow.TransactionProposalKey(address: Flow.Address(hex: fromAddress), keyIndex: toKeyIndex)
            }
            
            authorizers {
                Flow.Address(hex: fromAddress)
            }
            
            gasLimit {
                9999
            }
        }
    }
    
    static func fetchEVMTransactionResult(txid: String) async throws -> EVMTransactionExecuted {
        let result = try await flow.getTransactionResultById(id: .init(hex: txid))
        let event = result.events.filter { event in
            event.type == "evm.TransactionExecuted"
        }.first
        guard let event = event else {
            throw EVMError.transactionResult
        }
        let model: EVMTransactionExecuted = try event.payload.decode()
        log.debug("[EVM] result ==> \(model.transactionHash)")
        return model
    }
    //transferFlowToEvmAddress
    static func sendFlowToEvm(evmAddress: String, amount: Decimal, gas: UInt64) async throws -> Flow.ID {
        let originCadence = CadenceManager.shared.current.evm?.transferFlowToEvmAddress?.toFunc() ?? ""
        let cadenceStr = originCadence.replace(by: ScriptAddress.addressMap())
        let fromKeyIndex = WalletManager.shared.keyIndex
        
        guard let fromAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                cadenceStr
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            arguments {
                [
                    .string(evmAddress),
                    .ufix64(amount),
                    .uint64(gas)
                ]
            }
            proposer {
                Flow.TransactionProposalKey(address: Flow.Address(hex: fromAddress), keyIndex: fromKeyIndex)
            }
            
            authorizers {
                Flow.Address(hex: fromAddress)
            }
            
            gasLimit {
                9999
            }
        }
    }
    
    static func bridgeToken(address: String,contractName: String, amount: Decimal, fromEvm: Bool, decimals: Int) async throws -> Flow.ID {
        let originCadence = (fromEvm ? CadenceManager.shared.current.bridge?.bridgeTokensFromEvm?.toFunc()
        : CadenceManager.shared.current.bridge?.bridgeTokensToEvm?.toFunc()) ?? ""
        let cadenceStr = originCadence.replace(by: ScriptAddress.addressMap())
        var amountValue = Flow.Cadence.FValue.ufix64(amount)
        if let result = Utilities.parseToBigUInt(amount.description,decimals: decimals) , fromEvm {
           amountValue = Flow.Cadence.FValue.uint256(result)
        }
        
        let fromKeyIndex = WalletManager.shared.keyIndex
        
        guard let fromAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                cadenceStr
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            arguments {
                [
                    .address(Flow.Address(hex: address)),
                    .string(contractName),
                    amountValue
                ]
            }
            proposer {
                Flow.TransactionProposalKey(address: Flow.Address(hex: fromAddress), keyIndex: fromKeyIndex)
            }
            
            authorizers {
                Flow.Address(hex: fromAddress)
            }
            
            gasLimit {
                9999
            }
        }
    }
    
    static func bridgeNFTToEVM(contractAddress address: String, contractName name: String, ids: [UInt64], fromEvm: Bool) async throws -> Flow.ID {
        let originCadence = (fromEvm ? CadenceManager.shared.current.bridge?.batchBridgeNFTFromEvm?.toFunc()
        : CadenceManager.shared.current.bridge?.batchBridgeNFTToEvm?.toFunc()) ?? ""
        let cadenceStr = originCadence.replace(by: ScriptAddress.addressMap())
        let fromKeyIndex = WalletManager.shared.keyIndex
        let idMaped = fromEvm ? ids.map{ Flow.Cadence.FValue.uint256(BigUInt($0))} : ids.map { Flow.Cadence.FValue.uint64($0) }
        
        guard let fromAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                cadenceStr
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            arguments {
                [
                    .address(Flow.Address(hex: address)),
                    .string(name),
                    .array(idMaped)
                ]
            }
            proposer {
                Flow.TransactionProposalKey(address: Flow.Address(hex: fromAddress), keyIndex: fromKeyIndex)
            }
            
            authorizers {
                Flow.Address(hex: fromAddress)
            }
            
            gasLimit {
                9999
            }
        }
    }
}



extension Data {
    var cadenceValue: Flow.Cadence.FValue {
        .array(map{ $0.cadenceValue })
    }
}

extension UInt8 {
    var cadenceValue: Flow.Cadence.FValue {
        Flow.Cadence.FValue.uint8(self)
    }
}
