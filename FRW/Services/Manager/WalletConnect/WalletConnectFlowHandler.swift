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
    
    func accounts() {}

    func chainId(sessionProposal: Session.Proposal) -> Flow.ChainID? {
        guard let chains = sessionProposal.requiredNamespaces[nameTag]?.chains,
              let reference = chains.first(where: { $0.namespace == nameTag })?.reference
        else {
            return nil
        }
        return Flow.ChainID(name: reference.lowercased())
    }

    // TODO: validate that the chains are both testnet/both mainnet
    func approveProposalNamespace(
        required: ProposalNamespace?,
        optional: ProposalNamespace?
    ) throws -> [String: SessionNamespace]? {
        // Retrieve the primary wallet address; if missing, approval can’t continue.
        guard let account = WalletManager.shared.getPrimaryWalletAddress() else {
            return nil
        }
        
        // This dictionary will map each namespace (e.g., "eip155") to a SessionNamespace.
        var namespaces: [String: SessionNamespace] = [:]
        
        // Helper function that processes one proposal namespace (required or optional)
        func process(proposal: ProposalNamespace?) {
            guard let proposal = proposal, let chains = proposal.chains else { return }
            // Use the proposal’s methods and events; assume these are sets.
            let proposalMethods = proposal.methods
            let proposalEvents = proposal.events
            
            for chain in chains {
                let accountString = "\(chain.absoluteString):\(account)"
                guard let accountObj = WalletConnectSign.Account(accountString) else { continue }
                
                if var existingNamespace = namespaces[chain.namespace] {
                    // Merge the namespaces on conflict
                    existingNamespace.accounts.append(accountObj)
                    existingNamespace.methods.formUnion(proposalMethods)
                    existingNamespace.events.formUnion(proposalEvents)
                    existingNamespace.chains = (existingNamespace.chains ?? []) + [chain]
                    
                    namespaces[chain.namespace] = existingNamespace
                } else {
                    // Create a new session namespace for this namespace key.
                    let newNamespace = SessionNamespace(
                        chains: [chain],
                        accounts: [accountObj],
                        methods: proposalMethods,
                        events: proposalEvents
                    )
                    namespaces[chain.namespace] = newNamespace
                }
            }
        }
        
        // Process both required and optional proposals.
        process(proposal: required)
        process(proposal: optional)
        
        return namespaces
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
