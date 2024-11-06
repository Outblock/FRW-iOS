//
//  WalletConnectHandler.swift
//  FRW
//
//  Created by cat on 2024/4/16.
//

import Flow
import Foundation
import WalletConnectSign

// https://github.com/onflow/flow-evm-gateway?tab=readme-ov-file#evm-gateway-endpoints

struct WalletConnectHandler {
    private var allowNamespaces: [String] {
        return [
            flowHandler.nameTag,
            EVMHandler.nameTag,
        ]
    }

    private let flowHandler = WalletConnectFlowHandler()
    private let EVMHandler = WalletConnectEVMHandler()

    private func current(sessionProposal: Session.Proposal) -> WalletConnectChildHandlerProtocol {
        let namespaces = namespaceTag(sessionProposal: sessionProposal)
        if namespaces.contains(EVMHandler.nameTag) {
            return EVMHandler
        }
        return flowHandler
    }

    private func current(request: WalletConnectSign.Request) -> WalletConnectChildHandlerProtocol {
        let chainId = request.chainId
        if chainId.namespace.contains(EVMHandler.nameTag) {
            return EVMHandler
        }
        return flowHandler
    }
    
    func isEVM(with sessionProposal: Session.Proposal) -> Bool {
        let namespaces = namespaceTag(sessionProposal: sessionProposal)
        return namespaces.contains(EVMHandler.nameTag)
    }

    func isAllowedSession(sessionProposal: Session.Proposal) -> Bool {
        let namespaces = namespaceTag(sessionProposal: sessionProposal)
        let result = allowNamespaces.filter { namespaces.contains($0) }
        return result.count > 0
    }

    func chainReference(sessionProposal: Session.Proposal) -> String? {
        let handle = current(sessionProposal: sessionProposal)
        return handle.chainReference(sessionProposal: sessionProposal)
    }

    func sessionInfo(sessionProposal: Session.Proposal) -> SessionInfo {
        let handle = current(sessionProposal: sessionProposal)
        let info = handle.sessionInfo(sessionProposal: sessionProposal)
        return info
    }

    func chainId(sessionProposal: Session.Proposal) -> Flow.ChainID? {
        let handle = current(sessionProposal: sessionProposal)
        return handle.chainId(sessionProposal: sessionProposal)
    }

    func approveSessionNamespaces(sessionProposal: Session.Proposal) throws -> [String: SessionNamespace] {
        let handle = current(sessionProposal: sessionProposal)
        return try handle.approveSessionNamespaces(sessionProposal: sessionProposal)
    }

    func currentType(sessionProposal: Session.Proposal) -> WalletConnectHandlerType {
        let handle = current(sessionProposal: sessionProposal)
        return handle.type
    }

    func handlePersonalSignRequest(request: WalletConnectSign.Request, confirm: @escaping (String) -> Void, cancel: @escaping () -> Void) {
        let handle = current(request: request)
        handle.handlePersonalSignRequest(request: request, confirm: confirm, cancel: cancel)
    }

    func handleSendTransactionRequest(request: WalletConnectSign.Request, confirm: @escaping (String) -> Void, cancel: @escaping () -> Void) {
        let handle = current(request: request)
        handle.handleSendTransactionRequest(request: request, confirm: confirm, cancel: cancel)
    }
    
    func handleSignTypedDataV4(request: WalletConnectSign.Request, confirm: @escaping (String) -> Void, cancel: @escaping () -> Void) {
        let handle = current(request: request)
        handle.handleSignTypedDataV4(request: request, confirm: confirm, cancel: cancel)
    }
    
    func handleWatchAsset(request: WalletConnectSign.Request,confirm: @escaping (String) -> Void, cancel: @escaping () -> Void) {
        let handle = current(request: request)
        handle.handleWatchAsset(request: request, confirm: confirm, cancel: cancel)
    }
}

extension WalletConnectHandler {
    private func namespaceTag(sessionProposal: Session.Proposal) -> [String] {
        return Array(sessionProposal.requiredNamespaces.keys) + Array((sessionProposal.optionalNamespaces ?? [:]).keys)
    }
}
