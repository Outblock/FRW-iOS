//
//  WalletConnectFlowHandler.swift
//  FRW
//
//  Created by cat on 2024/4/16.
//

import Flow
import Foundation
import WalletConnectSign

struct WalletConnectFlowHandler: WalletConnectChildHandlerProtocol {
    var type: WalletConnectHandlerType {
        return .flow
    }

    var nameTag: String {
        return "flow"
    }

    func chainId(sessionProposal: Session.Proposal) -> Flow.ChainID? {
        guard let chains = sessionProposal.requiredNamespaces[nameTag]?.chains,
              let reference = chains.first(where: { $0.namespace == nameTag })?.reference
        else {
            return nil
        }
        return Flow.ChainID(name: reference.lowercased())
    }

    func approveSessionNamespaces(sessionProposal: Session.Proposal) throws -> [String: SessionNamespace] {
        guard let account = WalletManager.shared.getPrimaryWalletAddress() else {
            return [:]
        }

        var sessionNamespaces = [String: SessionNamespace]()
        sessionProposal.requiredNamespaces.forEach {
            let caip2Namespace = $0.key
            let proposalNamespace = $0.value
            if let chains = proposalNamespace.chains {
                let accounts = Array(chains.compactMap { WalletConnectSign.Account($0.absoluteString + ":\(account)") })
                let sessionNamespace = SessionNamespace(accounts: accounts, methods: proposalNamespace.methods, events: proposalNamespace.events)
                sessionNamespaces[caip2Namespace] = sessionNamespace
            }
        }
        return sessionNamespaces
    }

    func handlePersonalSignRequest(request _: Request, confirm _: @escaping (String) -> Void, cancel _: @escaping () -> Void) {}

    func handleSendTransactionRequest(request _: WalletConnectSign.Request, confirm _: @escaping (String) -> Void, cancel: @escaping () -> Void) {
        cancel()
    }
    
    func handleSignTypedDataV4(request: Request, confirm: @escaping (String) -> Void, cancel: @escaping () -> Void) {
        cancel()
    }
}
