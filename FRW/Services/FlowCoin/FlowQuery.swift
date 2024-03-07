//
//  LLCadence.swift
//  Flow Reference Wallet
//
//  Created by cat on 2022/5/2.
//

import Combine
import Flow
import Foundation

typealias TokenCadence = LLCadence<LLCadenceAction.token>
typealias BalanceCadence = LLCadence<LLCadenceAction.balance>
typealias NFTCadence = LLCadence<LLCadenceAction.nft>

enum LLCadenceAction {
    enum token {}
    enum balance {}
    enum nft {}
}

struct LLCadence<T> {}

//MARK: Check Token vault is enabled
extension LLCadence where T == LLCadenceAction.token {
    static func tokenEnable(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
        
        let cadence =
            """
              import FungibleToken from 0xFungibleToken
              <TokenImports>
              <TokenFunctions>
              pub fun main(address: Address) : [Bool] {
                return [<TokenCall>]
              }
            """
            
            .replacingOccurrences(of: "<TokenImports>", with: importRow(with: tokens, at: network))
            .replacingOccurrences(of: "<TokenFunctions>", with: tokenEnableFunc(with: tokens, at: network))
            .replacingOccurrences(of: "<TokenCall>", with: tokenEnableCalls(with: tokens, at: network))

        return cadence
    }
    
    static func tokenTransfer(token: TokenModel, at network: Flow.ChainID) -> String {
        
        let transferTokenWithInbox = CadenceManager.shared.current.domain.transferInboxTokens.toFunc()
        
        let script = network == .crescendo ?
        CadenceTemplate.transferToken : transferTokenWithInbox
        return script
            .replace(by: ScriptAddress.addressMap())
            .buildTokenInfo(token, chainId: network)
    }

    static private func tokenEnableFunc(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
        let tokenFunctions = tokens.map { token in
            """
              pub fun check<Token>Vault(address: Address) : Bool {
                let receiver: Bool = getAccount(address) \
                .getCapability<&<Token>.Vault{FungibleToken.Receiver}>(<TokenReceiverPath>) \
                .check()
                let balance: Bool = getAccount(address) \
                 .getCapability<&<Token>.Vault{FungibleToken.Balance}>(<TokenBalancePath>) \
                 .check()
                 return receiver && balance
              }

            """
            .buildTokenInfo(token, chainId: network)
        }.joined(separator: "\n")
        return tokenFunctions
    }

    static private func tokenEnableCalls(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
        let tokenCalls = tokens.map { token in
            """
            check<Token>Vault(address: address)
            """
            .buildTokenInfo(token, chainId: network)
        }
        .joined(separator: ",")
        return tokenCalls
    }
}

//MARK: Get Token Balance
extension LLCadence where T == LLCadenceAction.balance {
    
    static func balance(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
        let cadence =
            """
            import FungibleToken from 0xFungibleToken
            <TokenImports>
            <TokenFunctions>
            pub fun main(address: Address) : [UFix64] {
              return [<TokenCall>]
            }
            """
            .replace(by: ScriptAddress.addressMap())
            .replacingOccurrences(of: "<TokenImports>", with: importRow(with: tokens, at: network))
            .replacingOccurrences(of: "<TokenFunctions>", with: balanceFunc(with: tokens, at: network))
            .replacingOccurrences(of: "<TokenCall>", with: balanceCalls(with: tokens, at: network))
        return cadence
    }
    
    static private func balanceFunc(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
        let balanceFunctions = tokens.map { token in
            """
              pub fun balance<Token>Func(address: Address) : UFix64 {
                let account = getAccount(address)
                let vaultRef = account \
                .getCapability(<TokenBalancePath>) \
                .borrow<&<Token>.Vault{FungibleToken.Balance}>() \
                ?? panic("Could not borrow Balance capability")
                return vaultRef.balance
              }
            """
                .buildTokenInfo(token, chainId: network)
        }
            .joined(separator: "\n")
        return balanceFunctions
    }
    
    static private func balanceCalls(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
        let balanceCalls =  tokens.map { token in
            """
            balance<Token>Func(address: address)
            """
                .buildTokenInfo(token, chainId: network)
        }
            .joined(separator: ",")
        return balanceCalls
    }
    
}

//MARK: Body of Check Token vault is enabled
extension LLCadence {
    
    static private func importRow(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
        let tokenImports = tokens.map { token in
            """
            import <Token> from <TokenAddress>
            
            """
            .buildTokenInfo(token, chainId: network)
        }.joined(separator: "\r\n")
        return tokenImports
    }
    
}

//MARK: NFT

extension LLCadence where T == LLCadenceAction.nft {
    
    static func collectionListCheckEnabled(with list: [NFTCollectionInfo], on network: Flow.ChainID) -> String {
        let tokenImports = list.map {
            $0.formatCadence(script: "import <Token> from <TokenAddress>")
        }.joined(separator: "\r\n")

        let tokenFunctions = list.map {
            $0.formatCadence(script:
                """
                pub fun check<Token>Vault(address: Address) : Bool {
                    let account = getAccount(address)
                    let vaultRef = account
                    .getCapability<&{NonFungibleToken.CollectionPublic}>(<TokenCollectionPublicPath>)
                    .check()
                    return vaultRef
                }
                """
            )
        }.joined(separator: "\r\n")

        let tokenCalls = list.map {
            $0.formatCadence(script:
                """
                check<Token>Vault(address: address)
                """
            )
        }.joined(separator: ",")

        let cadence =
            """
            import NonFungibleToken from 0xNonFungibleToken
            <TokenImports>
            
            <TokenFunctions>
            
            pub fun main(address: Address) : [Bool] {
                return [<TokenCall>]
            }
            """
            .replace(by: ScriptAddress.addressMap())
            .replacingOccurrences(of: "<TokenFunctions>", with: tokenFunctions)
            .replacingOccurrences(of: "<TokenImports>", with: tokenImports)
            .replacingOccurrences(of: "<TokenCall>", with: tokenCalls)
        return cadence
    }
    
    static func collectionListIdCheck(with list: [NFTCollectionInfo], on network: Flow.ChainID) -> String {
        let tokenImports = list.map {
            $0.formatCadence(script: "import <NFT> from <NFTAddress>")
        }.joined(separator: "\r\n")

        let tokenFunctions = list.map {
            $0.formatCadence(script:
                """
                if let col = owner.getCapability(<CollectionPublicPath>)
                        .borrow<&{<CollectionPublic>}>() {
                            ids[<CollectionName>] = col.getIDs()
                }
                """
            )
        }.joined(separator: "\r\n")

        let cadence =
            """
            import NonFungibleToken from 0xNonFungibleToken
            <TokenImports>
            
            pub fun main(address: Address) : {String: [UInt64]}  {
                let owner = getAccount(ownerAddress)
                let ids: {String: [UInt64]} = {}
            
                <TokenFunctions>
            
                return ids
            }
            """
            .replace(by: ScriptAddress.addressMap())
            .replacingOccurrences(of: "<TokenFunctions>", with: tokenFunctions)
            .replacingOccurrences(of: "<TokenImports>", with: tokenImports)
        return cadence
    }
}


extension String {
    func buildTokenInfo(_ token: TokenModel, chainId: Flow.ChainID) -> String {
        let dict = [
            "<Token>" : token.contractName,
            "<TokenAddress>": token.address.addressByNetwork(chainId) ?? "0x",
            "<TokenBalancePath>": token.storagePath.balance,
            "<TokenReceiverPath>": token.storagePath.receiver,
            "<TokenStoragePath>": token.storagePath.vault
        ]
        return replace(by: dict)
    }
}

extension String {
    func replace(by dict: [String: String]) -> String {
        var string = self
        for (key, value) in dict {
            string = string.replacingOccurrences(of: key, with: value)
        }
        return string
    }
}

extension NFTCollectionInfo {
    func formatCadence(script: String, chainId: Flow.ChainID = flow.chainID) -> String {
        let newScript = script
            .replacingOccurrences(of: "<NFT>", with: contractName.trim())
            .replacingOccurrences(of: "<NFTAddress>", with: address)
            .replacingOccurrences(of: "<CollectionStoragePath>", with: path.storagePath)
            .replacingOccurrences(of: "<CollectionPublic>", with: path.publicCollectionName)
            .replacingOccurrences(of: "<CollectionPublicPath>", with: path.publicPath)
            .replacingOccurrences(of: "<Token>", with: contractName.trim())
            .replacingOccurrences(of: "<TokenAddress>", with: address)
            .replacingOccurrences(of: "<TokenCollectionStoragePath>", with: path.storagePath)
            .replacingOccurrences(of: "<TokenCollectionPublic>", with: path.publicCollectionName)
            .replacingOccurrences(of: "<TokenCollectionPublicPath>", with: path.publicPath)
            .replacingOccurrences(of: "<CollectionPublicType>", with: path.publicType)
            .replacingOccurrences(of: "<CollectionPrivateType>", with: path.privateType)
        
        return newScript.replace(by: ScriptAddress.addressMap())
    }
}

extension TokenModel {
    func formatCadence(cadence: String) -> String {
        let dict = [
            "<Token>": contractName,
            "<TokenAddress>": getAddress() ?? "0x",
            "<TokenReceiverPath>": storagePath.receiver,
            "<TokenBalancePath>": storagePath.balance,
            "<TokenStoragePath>": storagePath.vault
        ]
        
        return cadence.replace(by: dict).replace(by: ScriptAddress.addressMap())
    }
}


