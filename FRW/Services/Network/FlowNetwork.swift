//
//  FlowNetwork.swift
//  Flow Reference Wallet
//
//  Created by Hao Fu on 30/4/2022.
//

import Combine
import Flow
import Foundation
import BigInt

class FlowNetwork {
    static func setup() {
        let type = LocalUserDefaults.shared.flowNetwork.toFlowType()
        log.debug("did setup flow chainID to \(LocalUserDefaults.shared.flowNetwork.rawValue)")
        flow.configure(chainID: type)
    }
}

// MARK: - Token

extension FlowNetwork {
    static func checkTokensEnable(address: Flow.Address, tokens: [TokenModel]) async throws -> [Bool] {
        let cadence = TokenCadence.tokenEnable(with: tokens, at:flow.chainID)
        return try await fetch(at: address, by: cadence)
    }

    static func fetchBalance(at address: Flow.Address, with tokens: [TokenModel]) async throws -> [Double] {
        let cadence = BalanceCadence.balance(with: tokens, at: flow.chainID)
        return try await fetch(at: address, by: cadence)
    }
    
    static func enableToken(at address: Flow.Address, token: TokenModel) async throws -> Flow.ID {
        let cadenceString = token.formatCadence(cadence: CadenceTemplate.addToken)
        
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                address
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
        
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                WalletManager.shared.getPrimaryWalletAddress() ?? ""
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
}

// MARK: - NFT

extension FlowNetwork {
    static func checkCollectionEnable(address: Flow.Address, list: [NFTCollectionInfo]) async throws -> [Bool] {
        let cadence = NFTCadence.collectionListCheckEnabled(with: list, on: flow.chainID)
        return try await fetch(at: address, by: cadence)
    }
    
    static func addCollection(at address: Flow.Address, collection: NFTCollectionInfo) async throws -> Flow.ID {
        let cadenceString = collection.formatCadence(script: CadenceTemplate.nftCollectionEnable)
        
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                address
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
        
        let cadenceString = collection.formatCadence(script: nft.isNBA ? CadenceTemplate.nbaNFTTransfer : CadenceTemplate.nftTransfer)
        
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.Address(hex: fromAddress)
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
        let cadence = CadenceTemplate.queryAddressByDomainFind
        return try await fetch(cadence: cadence, arguments: [.string(domain)])
    }
    
    static func queryAddressByDomainFlowns(domain: String, root: String = "fn") async throws -> String {
        let cadence = CadenceTemplate.queryAddressByDomainFlowns
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
        
        let cadenceString = coin.formatCadence(cadence: CadenceTemplate.claimInboxToken)
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.Address(hex: address)
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
        
        let cadenceString = collection.formatCadence(script: CadenceTemplate.claimInboxNFT)
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.Address(hex: address)
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
        
        var cadenceString = isFrom ? CadenceTemplate.swapFromTokenToOtherToken : CadenceTemplate.swapOtherTokenToFromToken
        cadenceString = cadenceString
            .replace(by: ["Token1Name": tokenName, "Token1Addr": tokenAddress])
            .replace(by: ScriptAddress.addressMap())
        
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
        
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.Address(hex: address)
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
        return try await self.fetch(cadence: CadenceTemplate.checkStakingIsEnabled, arguments: [])
    }
    
    static func accountStakingIsSetup() async throws -> Bool {
        let address = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        return try await self.fetch(cadence: CadenceTemplate.checkAccountStakingIsSetup, arguments: [.address(address)])
    }
    
    static func claimUnstake(nodeID: String, delegatorId: Int, amount: Decimal) async throws -> Flow.ID {
        guard let walletAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LilicoError.emptyWallet
        }
        
        let address = Flow.Address(hex: walletAddress)
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                CadenceTemplate.Stake.claimUnstake
                    .replace(by: ScriptAddress.addressMap())
            }
            
            arguments {
                [.string(nodeID), .uint32(UInt32(delegatorId)), .ufix64(amount)]
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                address
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
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                CadenceTemplate.Stake.restakeUnstake
                    .replace(by: ScriptAddress.addressMap())
            }
            
            arguments {
                [.string(nodeID), .uint32(UInt32(delegatorId)), .ufix64(amount)]
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                address
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
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                CadenceTemplate.Stake.claimReward
                    .replace(by: ScriptAddress.addressMap())
            }
            
            arguments {
                [.string(nodeID), .uint32(UInt32(delegatorId)), .ufix64(amount)]
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                address
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
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                CadenceTemplate.Stake.reSatkeReward
                    .replace(by: ScriptAddress.addressMap())
            }
            
            arguments {
                [.string(nodeID), .uint32(UInt32(delegatorId)), .ufix64(amount)]
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                address
            }
            
            authorizers {
                address
            }
        }
    }
    
    static func setupAccountStaking() async throws -> Bool {
        let cadenceString = CadenceTemplate.setupAccountStaking.replace(by: ScriptAddress.addressMap())
        
        guard let walletAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LilicoError.emptyWallet
        }
        let address = Flow.Address(hex: walletAddress)
        
        let txId = try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                address
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
    
    static func createDelegatorId(providerId: String) async throws -> Bool {
        let cadenceString = CadenceTemplate.createDelegatorId.replace(by: ScriptAddress.addressMap())
        let address = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        
        let txId = try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                address
            }
            
            authorizers {
                address
            }
            
            arguments {
                [.string(providerId), .ufix64(0)]
            }
            
            gasLimit {
                9999
            }
        })
        
        let result = try await txId.onceSealed()
        
        if result.isFailed {
            debugPrint("FlowNetwork: createDelegatorId failed msg: \(result.errorMessage)")
            return false
        }
        
        return true
    }
    
    static func stakeFlow(providerId: String, delegatorId: Int, amount: Double) async throws -> Flow.ID {
        let cadenceString = CadenceTemplate.stakeFlow.replace(by: ScriptAddress.addressMap())
        let address = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        
        let txId = try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                address
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
        let cadenceString = CadenceTemplate.unstakeFlow.replace(by: ScriptAddress.addressMap())
        let address = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        
        let txId = try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                address
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
        let response: [StakingNode] = try await self.fetch(at: address, by: CadenceTemplate.queryStakeInfo)
        debugPrint("FlowNetwork -> queryStakeInfo, response = \(response)")
        return response
    }
    
    static func getStakingApyByWeek() async throws -> Double {
        let result: Decimal = try await fetch(cadence: CadenceTemplate.getApyByWeek, arguments: [])
        
        return result.doubleValue
    }
    
    static func getStakingApyByYear() async throws -> Double {
        let result: Decimal = try await fetch(cadence: CadenceTemplate.getApyByYear, arguments: [])

        return result.doubleValue
    }
    
    static func getDelegatorInfo() async throws -> [String: Int]? {
        let address = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        let replacedCadence = CadenceTemplate.getDelegatorInfo.replace(by: ScriptAddress.addressMap())
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
        let response: [String] = try await self.fetch(at: address, by: CadenceTemplate.queryChildAccountList)
        return response
    }
    
    static func unlinkChildAccount(_ address: String) async throws -> Flow.ID {
        let cadenceString = CadenceTemplate.unlinkChildAccount.replace(by: ScriptAddress.addressMap())
        let walletAddress = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        
        let txId = try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                walletAddress
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
        let replacedCadence = CadenceTemplate.queryChildAccountMeta.replace(by: ScriptAddress.addressMap())
        let rawResponse = try await flow.accessAPI.executeScriptAtLatestBlock(script: Flow.Script(text: replacedCadence),
                                                                           arguments: [.address(address)])

        guard let decode = rawResponse.decode() as? [String: Any?] else {
            return []
        }

        let result: [ChildAccount] = decode.keys.compactMap { key in
            guard let value = decode[key],
                  let value = value,
                  let data = try? JSONSerialization.data(withJSONObject: value),
                  var model = try? JSONDecoder().decode(ChildAccount.self, from: data) else {
                return ChildAccount(address: key, name: nil, desc: nil, icon: nil, pinTime: 0)
            }
            
            model.addr = key
            return model
        }

        return result
    }
    
    static func editChildAccountMeta(_ address: String, name: String, desc: String, thumbnail: String) async throws -> Flow.ID {
        let cadenceString = CadenceTemplate.editChildAccount.replace(by: ScriptAddress.addressMap())
        let walletAddress = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        
        let txId = try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                walletAddress
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
        let cadenceString = CadenceTemplate.accessibleCollection.replace(by: ScriptAddress.addressMap())
        let parentAddress = Flow.Address(hex: parent)
        let childAddress = Flow.Address(hex: child)
        let response = try await flow.accessAPI
            .executeScriptAtLatestBlock(script: Flow.Script(text: cadenceString), arguments: [.address(parentAddress), .address(childAddress)])
            .decode([FlowModel.NFTCollection].self)
        return response 
    }
    
    static func fetchAccessibleFT(parent: String, child: String) async throws -> [FlowModel.TokenInfo] {
        let cadenceString = CadenceTemplate.accessibleFT.replace(by: ScriptAddress.addressMap())
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
    
    static func checkStorageInfo() async throws -> Flow.StorageInfo  {
        let address = Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
        return try await flow.checkStorageInfo(address: address)
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
        if isProcessing {
            return false
        }
        
        if isExpired {
            return true
        }
        
        return !errorMessage.isEmpty
    }
}
