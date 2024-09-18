//
//  FCLModel.swift
//  Flow Wallet
//
//  Created by Hao Fu on 30/7/2022.
//

import Foundation
import Flow

struct AuthnResponse: Codable {
    let fType: String?
    let fVsn: String?
    let status: Status
    var updates: Service?
    var local: Service?
    var data: AuthnData?
    let reason: String?
    let compositeSignature: AuthnData?
    var authorizationUpdates: Service?

    enum CodingKeys: String, CodingKey {
        case fType = "f_type"
        case fVsn = "f_vsn"
        case status
        case updates
        case local
        case data
        case reason
        case compositeSignature
        case authorizationUpdates
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fType = try? container.decode(String.self, forKey: .fType)
        fVsn = try? container.decode(String.self, forKey: .fVsn)
        status = try container.decode(Status.self, forKey: .status)
        updates = try? container.decode(Service.self, forKey: .updates)
        authorizationUpdates = try? container.decode(Service.self, forKey: .authorizationUpdates)
        do {
            local = try container.decode(Service.self, forKey: .local)
        } catch {
            let locals = try? container.decode([Service].self, forKey: .local)
            local = locals?.first
        }

        data = try? container.decode(AuthnData.self, forKey: .data)
        reason = try? container.decode(String.self, forKey: .reason)
        compositeSignature = try? container.decode(AuthnData.self, forKey: .compositeSignature)
    }
    
    init(fType: String?, fVsn: String?, status: Status, updates: Service? = nil, local: Service? = nil, data: AuthnData? = nil, reason: String?, compositeSignature: AuthnData?, authorizationUpdates: Service? = nil) {
        self.fType = fType
        self.fVsn = fVsn
        self.status = status
        self.updates = updates
        self.local = local
        self.data = data
        self.reason = reason
        self.compositeSignature = compositeSignature
        self.authorizationUpdates = authorizationUpdates
    }
}

struct AuthnData: Codable {
    let addr: String?
    let fType: String?
    let fVsn: String?
    let services: [Service]?
    var keyId: Int? = nil
    var proposer: Service? = nil
    var payer: [Service]? = nil
    var authorization: [Service]? = nil
    var signature: String? = nil
}

enum Status: String, Codable {
    case pending = "PENDING"
    case approved = "APPROVED"
    case declined = "DECLINED"
}

public struct FCLResponse: Codable {
    var fType: String = "Service"
    var fVsn: String = "1.0.0"
    let addr: String
    let type: String
    var services: [Service]? = []
    //        let cid: String
    //        let expiresAt: Date
    
    enum CodingKeys: String, CodingKey {
        case fType = "f_type"
        case fVsn = "f_vsn"
        case addr
        case type
        case services
    }
}

public enum FCLServiceType: String, Codable {
    case authn
    case authz
    case accountProof = "account-proof"
    case preAuthz = "pre-authz"
    case userSignature = "user-signature"
    case backChannel = "back-channel-rpc"
    case localView = "local-view"
    case openID = "open-id"
}

public enum FCLWalletConnectMethod: String, Codable {
    case preAuthz = "flow_pre_authz"
    case authn = "flow_authn"
    case authz = "flow_authz"
    case userSignature = "flow_user_sign"
    case accountProof = "flow_account_proof"
    
    case accountInfo = "frw_account_info"
    case addDeviceInfo = "frw_add_device_key"
    
    public init?(type: FCLServiceType) {
        switch type {
        case .preAuthz:
            self = .preAuthz
        case .authn:
            self = .authn
        case .authz:
            self = .authz
        case .userSignature:
            self = .userSignature
        case .accountProof:
            self = .accountProof
        default:
            return nil
        }
    }
}

public enum FCLServiceMethod: String, Codable {
    case httpPost = "HTTP/POST"
    case httpGet = "HTTP/GET"
    case iframe = "VIEW/IFRAME"
    case iframeRPC = "IFRAME/RPC"
    case walletConnect = "WC/RPC"
    case data = "DATA"
}

struct Identity: Codable {
    public let address: String
    let keyId: Int?
}

struct Provider: Codable {
    public let fType: String?
    public let fVsn: String?
    public let address: String
    public let name: String
    public let description: String?
    public let color: String?
    public let supportEmail: String?
    public let website: String?
    public let icon: String?
    
    enum CodingKeys: String, CodingKey {
        case fType = "f_type"
        case fVsn = "f_vsn"
        case address
        case name
        case description
        case color
        case supportEmail
        case website
        case icon
    }
}

struct ParamValue: Codable {
    var value: String

    init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer() {
            if let intVal = try? container.decode(Int.self) {
                value = String(intVal)
            } else if let doubleVal = try? container.decode(Double.self) {
                value = String(doubleVal)
            } else if let boolVal = try? container.decode(Bool.self) {
                value = String(boolVal)
            } else if let stringVal = try? container.decode(String.self) {
                value = stringVal
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "the container contains nothing serialisable")
            }
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not serialise"))
        }
    }
}


struct Service: Codable {
    var fType: String? = "Service"
    var fVsn: String? = "1.0.0"
    var type: FCLServiceType?
    var method: FCLServiceMethod?
    var endpoint: String?
    var uid: String?
    var id: String?
    var identity: Identity?
    var provider: Provider?
    var params: [String: String]?
    var data: AccountProof?

    enum CodingKeys: String, CodingKey {
        case fType = "f_type"
        case fVsn = "f_vsn"
        case type
        case method
        case endpoint
        case uid
        case id
        case identity
        case provider
        case params
        case data
    }
    
    init(fType: String?, fVsn: String?, type: FCLServiceType?, method: FCLServiceMethod?, endpoint: String?, uid: String?, id: String?, identity: Identity?, provider: Provider?, params: [String : String]?, data: AccountProof?) {
        self.fType = fType
        self.fVsn = fVsn
        self.type = type
        self.method = method
        self.endpoint = endpoint
        self.uid = uid
        self.id = id
        self.identity = identity
        self.provider = provider
        self.params = params
        self.data = data
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawValue = try? container.decode([String: ParamValue].self, forKey: .params)
        var result = [String: String]()
        rawValue?.compactMap { $0 }.forEach { key, value in
            result[key] = value.value
        }
        params = result
        fType = try? container.decode(String.self, forKey: .fType)
        fVsn = try? container.decode(String.self, forKey: .fVsn)
        type = try? container.decode(FCLServiceType.self, forKey: .type)
        method = try? container.decode(FCLServiceMethod.self, forKey: .method)
        endpoint = try? container.decode(String.self, forKey: .endpoint)
        uid = try? container.decode(String.self, forKey: .uid)
        id = try? container.decode(String.self, forKey: .id)
        identity = try? container.decode(Identity.self, forKey: .identity)
        provider = try? container.decode(Provider.self, forKey: .provider)
        data = try? container.decode(AccountProof.self, forKey: .data)
    }
}


struct AccountProof: Codable {
    let fType, fVsn, address, nonce: String
    let signatures: [AccountProofSignature]

    enum CodingKeys: String, CodingKey {
        case fType = "f_type"
        case fVsn = "f_vsn"
        case address, nonce, signatures
    }
}

// MARK: - Signature
struct AccountProofSignature: Codable {
    let fType, fVsn, addr: String
    let keyID: Int
    let signature: String

    enum CodingKeys: String, CodingKey {
        case fType = "f_type"
        case fVsn = "f_vsn"
        case addr
        case keyID = "keyId"
        case signature
    }
}
