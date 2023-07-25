//
//  JSModels.swift
//  Lilico
//
//  Created by Selina on 5/9/2022.
//

import UIKit

protocol FCLResponseProtocol {
    func uniqueId() -> String
}

struct JSFCLServiceModelWrapper: Codable {
    let service: Service
}

// MARK: -

struct FCLIdentity: Codable {
    let address: String
}

struct FCLProvider: Codable {
    let address: String
    let description: String
    let icon: String
    let name: String
}

struct FCLExtension: Codable {
    let endpoint: String?
    let f_type: String?
    let f_vsn: String?
    let id: String?
    let identity: FCLIdentity?
    let method: String?
    let provider: FCLProvider?
    let type: String?
    let uid: String?
}

struct FCLSimpleService: Codable {
    let type: FCLServiceType
}

struct FCLApp: Codable {
    let icon: String?
    let title: String?
}

struct FCLClient: Codable {
    let extensions: [FCLExtension]?
    let fclLibrary: String?
    let fclVersion: String?
    let hostname: String?
    let network: String?
}

struct FCLServices: Codable {
    let openIDScopes: String?
    
    enum CodingKeys: String, CodingKey {
        case openIDScopes = "OpenID.scopes"
    }
}

struct FCLResponseConfig: Codable {
    let app: FCLApp?
    let client: FCLClient?
    let services: FCLServices?
}

// MARK: -

struct FCLSimpleResponse: Codable {
    let service: FCLSimpleService
    let type: String
    let config: FCLResponseConfig?
    
    var serviceType: FCLServiceType {
        return service.type
    }
    
    var network: String? {
        return config?.client?.network
    }
    
    var networkIsMatch: Bool {
        guard let network = network, !network.isEmpty else {
            return true
        }
        
        return network.lowercased() == LocalUserDefaults.shared.flowNetwork.rawValue
    }
}

struct AuthzTransaction: Codable {
    let url: String?
    let title: String?
    let voucher: Voucher
}
