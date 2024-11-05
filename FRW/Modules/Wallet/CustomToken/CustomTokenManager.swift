//
//  CustomTokenManager.swift
//  FRW
//
//  Created by cat on 11/1/24.
//

import Foundation
import web3swift
import BigInt
import Web3Core


class CustomTokenManager: ObservableObject {
    
    @Published var list: [CustomToken] = []
    
    var allTokens: [CustomToken] = LocalUserDefaults.shared.customToken
    
    private var queue = DispatchQueue(label: "CustomToken.add")
    
    
    func refresh() {
        queue.sync {
            var result = findCurrent(list: allTokens)
            result = filterWhite(list: result)
            list = result
        }
    }
    
    private func findCurrent(list: [CustomToken]) -> [CustomToken] {
        guard let address = WalletManager.shared.getWatchAddressOrChildAccountAddressOrPrimaryAddress(), let userId = UserManager.shared.activatedUID else {
            return []
        }
        let currentNetwork = LocalUserDefaults.shared.flowNetwork
        let belong = EVMAccountManager.shared.selectedAccount != nil ? CustomToken.Belong.evm : .flow
        
        let result = list.filter { token in
            token.belongAddress == address && token.network == currentNetwork && token.belong == belong && token.userId == userId
        }
        return result
    }
    
    private func filterWhite(list: [CustomToken]) -> [CustomToken] {
        
        var result: [CustomToken] = []
        list.forEach { customToken in
            if !isInWhite(token: customToken) {
                result.append(customToken)
            }
        }
        return result
    }
    
    
    func isInWhite(token: CustomToken) -> Bool {
        guard let support = WalletManager.shared.supportedCoins else {
            return true
        }
        let filterList = support.filter { model in
            model.evmAddress?.lowercased() == token.address.lowercased()
        }
        return filterList.count > 0
    }
    
    func isExist(token: CustomToken) -> Bool {
        queue.sync {
            let result = allTokens.filter { model in
                token.belongAddress == model.belongAddress && token.network == model.network && token.belong == model.belong && token.userId == model.userId
            }
            return result.count > 0
        }
    }
    
    func add(token: CustomToken) async {
        guard !isExist(token: token) else {
            return
        }
        var tmpToken = token
        let balance = try? await fetchBalance(token: token)
        tmpToken.balance = balance
        queue.sync {
            allTokens.append(tmpToken)
            LocalUserDefaults.shared.customToken = allTokens
        }
        refresh()
        WalletManager.shared.addCustomToken(token: tmpToken)
    }
    
    private func update(token: CustomToken) {
        queue.sync {
            let index = allTokens.firstIndex { $0.address == token.address }
            guard let index  else {
                return
            }
            allTokens[index] = token
        }
    }
}

// EVM
extension CustomTokenManager {
    func findToken(evmAddress: String) async throws -> CustomToken? {
        let evmAddress = evmAddress.addHexPrefix()
        guard let uid = UserManager.shared.activatedUID, let belongAddress = WalletManager.shared.getWatchAddressOrChildAccountAddressOrPrimaryAddress() else {
            throw AddCustomTokenError.invalidProfile
        }
        
        guard let web3 = try await FlowProvider.Web3.default() else{
            throw AddCustomTokenError.providerFailed
        }
        let contratc = web3.contract(Web3Utils.erc20ABI, at: .init(evmAddress))
        async let decimalsRequest = contratc?.createReadOperation("decimals")?.callContractMethod()
        
        let decimals = try await decimalsRequest?["0"] as? BigUInt
        let decimalInt = Int(decimals?.description ?? "6") ?? 0
        
        async let symbolRequest = contratc?.createReadOperation("symbol")?.callContractMethod()
        async let nameRequest = contratc?.createReadOperation("name")?.callContractMethod()
        let result: [String] = try await [symbolRequest, nameRequest].compactMap{ $0?["0"] as? String }
        guard result.count == 2 else {
            return nil
        }
        
        let name = result[1]
        let symbol = result[0]
        
        let flowIdentifier = try? await FlowNetwork.getAssociatedFlowIdentifier(address: evmAddress)
        
        let token = CustomToken(
            address: evmAddress,
            decimals: decimalInt,
            name: name,
            symbol: symbol,
            flowIdentifier: flowIdentifier,
            userId: uid,
            belongAddress: belongAddress,
            belong: .evm
        )
        return token
    }
    
    func fetchAllEVMBalance() async {
        await withTaskGroup(of: Void.self) { group in
            allTokens.forEach { token in
                group.addTask { [weak self] in
                    do {
                        var model = token
                        let balance = try await self?.fetchBalance(token: model)
                        model.balance = balance
                        self?.update(token: model)
                    }
                    catch {
                        log.info("[Custom Token] fetch balance failed.\(token.address)")
                    }
                }
            }
        }
        refresh()
    }
    
    func fetchBalance(token: CustomToken) async throws -> BigUInt? {
        guard let coaAddresss = EVMAccountManager.shared.selectedAccount?.showAddress else {
            throw AddCustomTokenError.invalidProfile
        }
        guard let web3 = try await FlowProvider.Web3.default() else{
            throw AddCustomTokenError.providerFailed
        }
        let contratc = web3.contract(
            Web3Utils.erc20ABI,
            at: .init(token.address)
        )
        // Parameters is user wallet address
        let balanceRequest = try await contratc?.createReadOperation("balanceOf", parameters: [coaAddresss])?.callContractMethod()
        if let balanceUInt = balanceRequest?["balance"] as? BigUInt {
            return balanceUInt
        }
        return nil
    }
}

//MARK: - Model

struct CustomToken: Codable {

    enum Belong: Codable {
        case flow
        case evm
    }
    
    var address: String
    var decimals: Int
    var name: String
    var symbol: String
    var flowIdentifier: String?
    
    
    var userId: String
    var belongAddress: String
    var network: LocalUserDefaults.FlowNetworkType = .mainnet
    var belong: CustomToken.Belong = .flow
    // not store,
    var balance: BigUInt?
    
    func toToken() -> TokenModel {
        TokenModel(
            name: name,
            address: FlowNetworkModel(
                mainnet: address,
                testnet: address,
                crescendo: nil
            ),
            contractName: "",
            storagePath: FlowTokenStoragePath(balance: "", vault: "", receiver: ""),
            decimal: decimals,
            icon: nil,
            symbol: symbol,
            website: nil,
            evmAddress: nil
        )
    }
}

enum AddCustomTokenError: Error {
    case invalidProfile
    case providerFailed
    
    
}

