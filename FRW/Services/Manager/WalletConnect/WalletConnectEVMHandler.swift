//
//  WalletConnectEVMHandler.swift
//  FRW
//
//  Created by cat on 2024/4/16.
//

import Foundation
import WalletConnectSign
import Flow
import WalletConnectRouter
import Web3Wallet
import Web3Core
import web3swift
import BigInt

enum WalletConnectEVMMethod: String, Codable {
    case personalSign = "personal_sign"
}

struct WalletConnectEVMHandler: WalletConnectChildHandlerProtocol {
    var nameTag: String {
        return "eip155"
    }
    
    func chainId(sessionProposal: Session.Proposal) -> Flow.ChainID? {
        guard let chains = sessionProposal.requiredNamespaces[nameTag]?.chains,
              let reference = chains.first(where: { $0.namespace == nameTag })?.reference else {
            return nil
        }
        switch reference {
        case "646":
            return .previewnet
        case "747":
            return .mainnet
        default:
            return .unknown
        }
    }
    
    func approveSessionNamespaces(sessionProposal: Session.Proposal) throws -> [String : SessionNamespace] {
        guard let account = WalletManager.shared.evmAccount?.address else {
            return [:]
        }
        // Following properties are used to support all the required and optional namespaces for the testing purposes
        let supportedMethods = Set(sessionProposal.requiredNamespaces.flatMap { $0.value.methods } + (sessionProposal.optionalNamespaces?.flatMap { $0.value.methods } ?? []))
        let supportedEvents = Set(sessionProposal.requiredNamespaces.flatMap { $0.value.events } + (sessionProposal.optionalNamespaces?.flatMap { $0.value.events } ?? []))
        
        let supportedRequiredChains = sessionProposal.requiredNamespaces[nameTag]?.chains ?? []
        let supportedOptionalChains = sessionProposal.optionalNamespaces?[nameTag]?.chains ?? []
        let supportedChains = supportedRequiredChains.union(supportedOptionalChains) //supportedRequiredChains + supportedOptionalChains

        let supportedAccounts = Array(supportedChains).map { WalletConnectSign.Account(blockchain: $0, address: account)! }

        //TODO: #six
        /* Use only supported values for production. I.e:
        let supportedMethods = ["eth_signTransaction", "personal_sign", "eth_signTypedData", "eth_sendTransaction", "eth_sign"]
        let supportedEvents = ["accountsChanged", "chainChanged"]
        let supportedChains = [Blockchain("eip155:1")!, Blockchain("eip155:137")!]
        let supportedAccounts = [Account(blockchain: Blockchain("eip155:1")!, address: ETHSigner.address)!, Account(blockchain: Blockchain("eip155:137")!, address: ETHSigner.address)!]
        */
        let sessionNamespaces: [String: SessionNamespace] = try AutoNamespaces.build(
            sessionProposal: sessionProposal,
            chains: Array(supportedChains),
            methods: Array(supportedMethods),
            events: Array(supportedEvents),
            accounts: supportedAccounts
        )
        return sessionNamespaces
    }
    
    func handlePersonalSignRequest(request: Request, confirm: @escaping (String) -> (), cancel: @escaping () -> ()) {
        guard let data = message(sessionRequest: request) else {
            cancel()
            return
        }
        let title = "unknown"
        let url = "unknown"
        let vm = BrowserSignMessageViewModel(title: title,
                                             url: url,
                                             logo: nil,
                                             cadence: data.hexString)
        { result in
            if result {
                guard let addrStr = WalletManager.shared.getPrimaryWalletAddress() else {
                    HUD.error(title: "invalid_address".localized)
                    return
                }
                
                
                let address = Flow.Address(hex: addrStr)
                guard let hashedData = Utilities.hashPersonalMessage(data) else { return  }
                let joinData = Flow.DomainTag.user.normalize + hashedData
                guard let sig = signWithMessage(data: joinData) else {
                    HUD.error(title: "sign failed")
                    return
                }
                let keyIndex = BigUInt(WalletManager.shared.keyIndex)
                let proof = COAOwnershipProof(keyIninces: [keyIndex], address: address.data, capabilityPath: "evm", signatures: [sig])
                guard let encoded = RLP.encode(proof.rlpList) else {
                    return
                }
                confirm(encoded.hexString.addHexPrefix())
            } else {
                cancel()
            }
        }
        
        Router.route(to: RouteMap.Explore.signMessage(vm))
    }
    
    
}

extension WalletConnectEVMHandler {
    private func message(sessionRequest: Request) -> Data? {
        let message = try? sessionRequest.params.get([String].self)
        let decryptedMessage = message.map { Data(hex: $0.first ?? "") }
        return decryptedMessage
    }
    
    private func signWithMessage(data: Data) -> Data? {
        return WalletManager.shared.signSync(signableData: data)
    }
}