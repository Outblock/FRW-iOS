//
//  FCLAuthzResponse.swift
//  Flow Wallet
//
//  Created by Selina on 5/9/2022.
//

import Foundation

struct FCLAuthzResponse: Codable, FCLResponseProtocol {
    let body: Body
    let service: FCLSimpleService
    let config: FCLResponseConfig?
    let type: String

    var isSignAuthz: Bool {
        return service.type == .authz && body.f_type == "Signable" && body.roles.isSignAuthz
    }

    var isSignPayload: Bool {
        return service.type == .authz && body.f_type == "Signable" && body.roles.isSignPayload
    }

    var isSignEnvelope: Bool {
        return service.type == .authz && body.f_type == "Signable" && body.roles.isSignEnvelope
    }

    var isLinkAccount: Bool {
        return body.cadence.trim.hasPrefix("#allowAccountLinking")
    }

    func uniqueId() -> String {
        return "\(service.type.rawValue)-\(type)-\(body.roles.value)"
    }
}

extension FCLAuthzResponse {
    struct Body: Codable {
        let addr: String
        let cadence: String
        let f_type: String
        let f_vsn: String
        let keyId: Int
        let message: String
        let roles: Roles
        let voucher: Voucher
    }

    struct Roles: Codable {
        let authorizer: Bool
        let payer: Bool
        let proposer: Bool

        var isSignAuthz: Bool {
            return payer && authorizer && proposer
        }

        var isSignPayload: Bool {
            return !payer && authorizer && proposer
        }

        var isSignEnvelope: Bool {
            return payer && !authorizer && !proposer
        }

        var value: String {
            return "roles=\(proposer)-\(authorizer)-\(payer)"
        }
    }
}
