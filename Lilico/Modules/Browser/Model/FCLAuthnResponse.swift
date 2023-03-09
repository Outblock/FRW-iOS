//
//  FCLAuthnResponse.swift
//  Lilico
//
//  Created by Selina on 5/9/2022.
//

import UIKit
import Flow

private let accountProofTag = Flow.DomainTag.custom("FCL-ACCOUNT-PROOF-V0.0").normalize

struct FCLAuthnResponse: Codable, FCLResponseProtocol {
    let body: Body
    let service: FCLSimpleService
    let config: FCLResponseConfig?
    let type: String
    
    func uniqueId() -> String {
        return "\(service.type.rawValue)-\(type)"
    }
    
    func encodeAccountProof(address: String, includeDomaintag: Bool = true) -> Data? {
        guard let nonce = body.nonce, !nonce.isEmpty else {
            return Data()
        }
        
        guard let appId = body.appIdentifier else {
            debugPrint("Encode Message For Provable Authn Error: appIdentifier must be defined")
            return nil
        }
        
        let list: [Any] = [appId.data(using: .utf8) ?? Data(), Data(hex: address), Data(hex: nonce)]
        guard let rlp = RLP.encode(list) else {
            return nil
        }
        
        if includeDomaintag {
            return accountProofTag + rlp
        } else {
            return rlp
        }
    }
}

extension FCLAuthnResponse {
    struct Body: Codable {
        let extensions: [FCLExtension]?
        let timestamp: TimeInterval?
        let appIdentifier: String?
        let nonce: String?
    }
}
