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
        .flow
    }

    var nameTag: String {
        "flow"
    }

    func chainId(sessionProposal: Session.Proposal) -> Flow.ChainID? {
        guard let chains = sessionProposal.requiredNamespaces[nameTag]?.chains,
              let reference = chains.first(where: { $0.namespace == nameTag })?.reference
        else {
            return nil
        }
        return Flow.ChainID(name: reference.lowercased())
    }

    func approveSessionNamespaces(
        sessionProposal: Session
            .Proposal
    ) throws -> [String: SessionNamespace] {
        guard let account = WalletManager.shared.getPrimaryWalletAddress() else {
            return [:]
        }

        var sessionNamespaces = [String: SessionNamespace]()
        for requiredNamespace in sessionProposal.requiredNamespaces {
            let caip2Namespace = requiredNamespace.key
            let proposalNamespace = requiredNamespace.value
            if let chains = proposalNamespace.chains {
                let accounts = Array(
                    chains
                        .compactMap { WalletConnectSign.Account($0.absoluteString + ":\(account)") }
                )
                let sessionNamespace = SessionNamespace(
                    accounts: accounts,
                    methods: proposalNamespace.methods,
                    events: proposalNamespace.events
                )
                sessionNamespaces[caip2Namespace] = sessionNamespace
            }
        }
        return sessionNamespaces
    }

    func handlePersonalSignRequest(
        request _: Request,
        confirm _: @escaping (String) -> Void,
        cancel _: @escaping () -> Void
    ) {}

    func handleSendTransactionRequest(
        request _: WalletConnectSign.Request,
        confirm _: @escaping (String) -> Void,
        cancel: @escaping () -> Void
    ) {
        cancel()
    }

    func handleSignTypedDataV4(
        request _: Request,
        confirm _: @escaping (String) -> Void,
        cancel: @escaping () -> Void
    ) {
        cancel()
    }

    func handleWatchAsset(
        request _: Request,
        confirm _: @escaping (String) -> Void,
        cancel: @escaping () -> Void
    ) {
        cancel()
    }
}
