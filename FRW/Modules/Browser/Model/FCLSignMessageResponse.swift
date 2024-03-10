//
//  FCLSignMessageResponse.swift
//  Flow Wallet
//
//  Created by Selina on 5/9/2022.
//

import Foundation

struct FCLSignMessageResponse: Codable, FCLResponseProtocol {
    let body: Body?
    let config: FCLResponseConfig?
    let fclVersion: String
    let service: FCLSimpleService
    let type: String
    
    func uniqueId() -> String {
        return "\(service.type.rawValue)-\(type)-\(body?.message ?? "")"
    }
}

extension FCLSignMessageResponse {
    struct Body: Codable {
        let message: String?
    }
}
