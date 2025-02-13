//
//  WalletConnectHandler.swift
//  FRW
//
//  Created by cat on 2024/4/16.
//

import Flow
import Foundation
import WalletConnectSign

// MARK: - WalletConnectHandler

// https://github.com/onflow/flow-evm-gateway?tab=readme-ov-file#evm-gateway-endpoints

struct WalletConnectHandler {
    // MARK: Internal

    func isAllowedSession(sessionProposal: Session.Proposal) -> Bool {
        let namespaces = namespaceTag(sessionProposal: sessionProposal)
        let result = allowNamespaces.filter { namespaces.contains($0) }
        return !result.isEmpty
    }

    func sessionInfo(sessionProposal: Session.Proposal) -> SessionInfo {
        let appMetadata = sessionProposal.proposer
        let requiredNamespaces = sessionProposal.requiredNamespaces
        let info = SessionInfo(
            name: appMetadata.name,
            descriptionText: appMetadata.description,
            dappURL: appMetadata.url,
            iconURL: appMetadata.icons.first ?? "",
            chains: [],
            methods: [],
            pendingRequests: [],
            data: ""
        )
        return info
    }

    func approveSessionNamespaces(
        sessionProposal: Session.Proposal
    ) throws -> [String: SessionNamespace] {
        var approvedNamespaces: [String: SessionNamespace] = [:]
        
        // Process EVM if present in either required or optional namespaces.
        let reqEvm = sessionProposal.requiredNamespaces[EVMHandler.nameTag]
        let optEvm = sessionProposal.optionalNamespaces?[EVMHandler.nameTag]
        if reqEvm != nil || optEvm != nil {
            if let evmNS = try EVMHandler.approveProposalNamespace(required: reqEvm, optional: optEvm) {
                approvedNamespaces[EVMHandler.nameTag] = evmNS
            }
        }
        
        // Process FCL if present in either required or optional namespaces.
        let reqFlow = sessionProposal.requiredNamespaces[flowHandler.nameTag]
        let optFlow = sessionProposal.optionalNamespaces?[flowHandler.nameTag]
        if reqFlow != nil || optFlow != nil {
            if let flowNS = try flowHandler.approveProposalNamespace(required: reqFlow, optional: optFlow) {
                approvedNamespaces[flowHandler.nameTag] = flowNS
            }
        }
        
        return approvedNamespaces
    }

    func handlePersonalSignRequest(
        request: WalletConnectSign.Request,
        confirm: @escaping (String) -> Void,
        cancel: @escaping () -> Void
    ) {
        let handle = current(request: request)
        handle.handlePersonalSignRequest(request: request, confirm: confirm, cancel: cancel)
    }

    func handleSendTransactionRequest(
        request: WalletConnectSign.Request,
        confirm: @escaping (String) -> Void,
        cancel: @escaping () -> Void
    ) {
        let handle = current(request: request)
        handle.handleSendTransactionRequest(request: request, confirm: confirm, cancel: cancel)
    }

    func handleSignTypedDataV4(
        request: WalletConnectSign.Request,
        confirm: @escaping (String) -> Void,
        cancel: @escaping () -> Void
    ) {
        let handle = current(request: request)
        handle.handleSignTypedDataV4(request: request, confirm: confirm, cancel: cancel)
    }

    func handleWatchAsset(
        request: WalletConnectSign.Request,
        confirm: @escaping (String) -> Void,
        cancel: @escaping () -> Void
    ) {
        let handle = current(request: request)
        handle.handleWatchAsset(request: request, confirm: confirm, cancel: cancel)
    }

    // MARK: Private

    private let flowHandler = WalletConnectFlowHandler()
    private let EVMHandler = WalletConnectEVMHandler()

    private var allowNamespaces: [String] {
        [
            flowHandler.nameTag,
            EVMHandler.nameTag,
        ]
    }
    
    private func current(request: WalletConnectSign.Request) -> WalletConnectChildHandlerProtocol {
        let chainId = request.chainId
        if chainId.namespace.contains(EVMHandler.nameTag) {
            return EVMHandler
        }
        return flowHandler
    }
}

extension WalletConnectHandler {
    private func namespaceTag(sessionProposal: Session.Proposal) -> [String] {
        Array(sessionProposal.requiredNamespaces.keys) +
            Array((sessionProposal.optionalNamespaces ?? [:]).keys)
    }
}
