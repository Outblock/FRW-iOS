//
//  WalletConnectChildHandlerProtocol.swift
//  FRW
//
//  Created by cat on 2024/4/16.
//

import Foundation
import WalletConnectSign
import Flow

protocol WalletConnectChildHandlerProtocol {
    
    var nameTag: String { get }
    func sessionInfo(sessionProposal: Session.Proposal) -> SessionInfo
    func chainId(sessionProposal: Session.Proposal) -> Flow.ChainID?
    func approveSessionNamespaces(sessionProposal: Session.Proposal) throws -> [String: SessionNamespace]
    func handlePersonalSignRequest(request: WalletConnectSign.Request, confirm: @escaping (String)->(), cancel:@escaping ()->())
}

extension WalletConnectChildHandlerProtocol {
    
    func chainReference(sessionProposal: WalletConnectSign.Session.Proposal) -> String? {
        guard let chains = sessionProposal.requiredNamespaces[nameTag]?.chains, let reference = chains.first(where: { $0.namespace == nameTag })?.reference else {
            return nil
        }
        return reference
    }
    
    func sessionInfo(sessionProposal: Session.Proposal)  -> SessionInfo {
        let appMetadata = sessionProposal.proposer
        let requiredNamespaces = sessionProposal.requiredNamespaces
        let info = SessionInfo(
            name: appMetadata.name,
            descriptionText: appMetadata.description,
            dappURL: appMetadata.url,
            iconURL: appMetadata.icons.first ?? "",
            chains: requiredNamespaces[nameTag]?.chains ?? [],
            methods: requiredNamespaces[nameTag]?.methods ?? [],
            pendingRequests: [],
            data: ""
        )
        return info
    }
    
}