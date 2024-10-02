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
    case sendTransaction = "eth_sendTransaction"
}

struct WalletConnectEVMHandler: WalletConnectChildHandlerProtocol {
    
    var type: WalletConnectHandlerType {
        return .evm
    }
    
    var nameTag: String {
        return "eip155"
    }
    
    func chainId(sessionProposal: Session.Proposal) -> Flow.ChainID? {
        var reference: String?
        if let chains = sessionProposal.requiredNamespaces[nameTag]?.chains {
            reference = chains.first(where: { $0.namespace == nameTag })?.reference
        }
        if reference==nil, let chains = sessionProposal.optionalNamespaces?[nameTag]?.chains {
            reference = chains.first(where: { $0.namespace == nameTag })?.reference
        }
        //TODO: if not the list allowed, HOW
        switch reference {
        case "646":
            return .previewnet
        case "747":
            return .mainnet
        case "545":
            return .testnet
        default:
            return .unknown
        }
    }
    
    func approveSessionNamespaces(sessionProposal: Session.Proposal) throws -> [String : SessionNamespace] {
        guard let account = EVMAccountManager.shared.accounts.first?.address.addHexPrefix() else {
            return [:]
        }
        // Following properties are used to support all the required and optional namespaces for the testing purposes
        let supportedMethods = Set(sessionProposal.requiredNamespaces.flatMap { $0.value.methods } + (sessionProposal.optionalNamespaces?.flatMap { $0.value.methods } ?? []))
        let supportedEvents = Set(sessionProposal.requiredNamespaces.flatMap { $0.value.events } + (sessionProposal.optionalNamespaces?.flatMap { $0.value.events } ?? []))
        
        let supportedRequiredChains = sessionProposal.requiredNamespaces[nameTag]?.chains ?? []
        let supportedOptionalChains = sessionProposal.optionalNamespaces?[nameTag]?.chains ?? []
        let supportedChains = supportedRequiredChains + supportedOptionalChains

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
        let pair = try? Pair.instance.getPairing(for: request.topic)
        let title = pair?.peer?.name ?? "unknown"
        let url = pair?.peer?.url ?? "unknown"
        let logo = pair?.peer?.icons.first
        let vm = BrowserSignMessageViewModel(title: title,
                                             url: url,
                                             logo: logo,
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
    
    func handleSendTransactionRequest(request: WalletConnectSign.Request, confirm: @escaping (String)->(), cancel:@escaping ()->()) {
        
        let pair = try? Pair.instance.getPairing(for: request.topic)
        let title = pair?.peer?.name ?? "unknown"
        let url = pair?.peer?.url ?? "unknown"
        let logo = pair?.peer?.icons.first
        
        let originCadence = CadenceManager.shared.current.evm?.callContract?.toFunc() ?? ""
        
        let vm = BrowserAuthzViewModel(title: title,
                                             url: url,
                                             logo: logo,
                                             cadence: originCadence)
        { result in
            if result {
                Task {
                    do {
                        let result = try request.params.get([EVMTransactionReceive].self)
                        guard let receiveModel = result.first else {
                            cancel()
                            return
                        }
                        guard let toAddr = receiveModel.toAddress else {
                            cancel()
                            return
                        }
                        let tix = try await FlowNetwork.sendTransaction(amount: receiveModel.amount, data: receiveModel.dataValue, toAddress: toAddr, gas: receiveModel.gasValue)
                        let tixResult = try await tix.onceSealed()
                        if tixResult.isFailed {
                            HUD.error(title: "transaction failed")
                            cancel()
                            return
                        }
                        let model = try await FlowNetwork.fetchEVMTransactionResult(txid: tix.hex)
                        DispatchQueue.main.async {
                            confirm(model.hashString ?? "")
                        }
                    }
                    catch {
                        log.error("[EVM] send transaction failed \(error)")
                        cancel()
                    }
                }
            }
            else {
                cancel()
            }
        }
        Router.route(to: RouteMap.Explore.authz(vm))
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
