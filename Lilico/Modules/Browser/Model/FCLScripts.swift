//
//  FCLScripts.swift
//  Lilico
//
//  Created by Selina on 5/9/2022.
//

import Foundation
import Flow

class FCLScripts {
    private static let PreAuthzReplacement = "$PRE_AUTHZ_REPLACEMENT"
    private static let AddressReplacement = "$ADDRESS_REPLACEMENT"
    private static let KeyIDReplacement = "$KEY_ID_REPLACEMENT"
    private static let PayerAddressReplacement = "$PAYER_ADDRESS_REPLACEMENT"
    private static let SignatureReplacement = "$SIGNATURE_REPLACEMENT"
    private static let UserSignatureReplacement = "$USER_SIGNATURE_REPLACEMENT"
    private static let AccountProofReplacement = "$ACCOUNT_PROOF_REPLACEMENT"
    private static let NonceReplacement = "$NONCE_REPLACEMENT"
    
    private static let preAuthzResponse = """
        {
            "status": "APPROVED",
            "data": {
                "f_type": "PreAuthzResponse",
                "f_vsn": "1.0.0",
                "proposer": {
                    "f_type": "Service",
                    "f_vsn": "1.0.0",
                    "type": "authz",
                    "uid": "fcw#authz",
                    "endpoint": "chrome-extension://hpclkefagolihohboafpheddmmgdffjm/popup.html",
                    "method": "EXT/RPC",
                    "identity": {
                        "address": "$ADDRESS_REPLACEMENT",
                        "keyId": 0
                    }
                },
                "payer": [
                    {
                        "f_type": "Service",
                        "f_vsn": "1.0.0",
                        "type": "authz",
                        "uid": "fcw#authz",
                        "endpoint": "chrome-extension://hpclkefagolihohboafpheddmmgdffjm/popup.html",
                        "method": "EXT/RPC",
                        "identity": {
                            "address": "$PAYER_ADDRESS_REPLACEMENT",
                            "keyId": 0
                        }
                    }
                ],
                "authorization": [
                    {
                        "f_type": "Service",
                        "f_vsn": "1.0.0",
                        "type": "authz",
                        "uid": "fcw#authz",
                        "endpoint": "chrome-extension://hpclkefagolihohboafpheddmmgdffjm/popup.html",
                        "method": "EXT/RPC",
                        "identity": {
                            "address": "$ADDRESS_REPLACEMENT",
                            "keyId": 0
                        }
                    }
                ]
            },
            "type": "FCL:VIEW:RESPONSE"
        }
    """
    
    private static let authnResponse = """
        {
          "f_type": "PollingResponse",
          "f_vsn": "1.0.0",
          "status": "APPROVED",
          "reason": null,
          "data": {
            "f_type": "AuthnResponse",
            "f_vsn": "1.0.0",
            "addr": "$ADDRESS_REPLACEMENT",
            "services": [
              {
                "f_type": "Service",
                "f_vsn": "1.0.0",
                "type": "authn",
                "uid": "fcw#authn",
                "endpoint": "ext:0x000",
                "id": "$ADDRESS_REPLACEMENT",
                "identity": {
                  "address": "$ADDRESS_REPLACEMENT"
                },
                "provider": {
                  "f_type": "ServiceProvider",
                  "f_vsn": "1.0.0",
                  "address": "$ADDRESS_REPLACEMENT",
                  "name": "Lilico Wallet"
                }
              },
              $PRE_AUTHZ_REPLACEMENT
              $USER_SIGNATURE_REPLACEMENT
              $ACCOUNT_PROOF_REPLACEMENT
              {
                "f_type": "Service",
                "f_vsn": "1.0.0",
                "type": "authz",
                "uid": "fcw#authz",
                "endpoint": "ext:0x000",
                "method": "EXT/RPC",
                "identity": {
                  "address": "$ADDRESS_REPLACEMENT",
                  "keyId": 0
                }
              }
            ],
            "paddr": null
          },
          "type": "FCL:VIEW:RESPONSE"
        }
    """
    
    private static let signMessageResponse = """
        {
          "f_type": "PollingResponse",
          "f_vsn": "1.0.0",
          "status": "APPROVED",
          "reason": null,
          "data": {
            "f_type": "CompositeSignature",
            "f_vsn": "1.0.0",
            "addr": "$ADDRESS_REPLACEMENT",
            "keyId": 0,
            "signature": "$SIGNATURE_REPLACEMENT"
          },
          "type": "FCL:VIEW:RESPONSE"
        }
    """
    
    private static let authnResponseUserSignature = """
        {
            "f_type": "Service",
            "f_vsn": "1.0.0",
            "type": "user-signature",
            "uid": "fcw#user-signature",
            "endpoint": "chrome-extension://hpclkefagolihohboafpheddmmgdffjm/popup.html",
            "method": "EXT/RPC"
        },
    """
    
    private static let authnResponseAccountProof = """
        {
            "f_type": "Service",
            "f_vsn": "1.0.0",
            "type": "account-proof",
            "uid": "fcw#account-proof",
            "endpoint": "chrome-extension://hpclkefagolihohboafpheddmmgdffjm/popup.html",
            "method": "EXT/RPC",
            "data": {
              "f_type": "account-proof",
              "f_vsn": "2.0.0",
              "address": "$ADDRESS_REPLACEMENT",
              "nonce": "$NONCE_REPLACEMENT",
              "signatures": [
                {
                  "f_type": "CompositeSignature",
                  "f_vsn": "1.0.0",
                  "addr": "$ADDRESS_REPLACEMENT",
                  "keyId": 0,
                  "signature": "$SIGNATURE_REPLACEMENT"
                }
              ]
            }
        },
    """
    
    private static let authzResponse = """
        {
          "f_type": "PollingResponse",
          "f_vsn": "1.0.0",
          "status": "APPROVED",
          "reason": null,
          "data": {
            "f_type": "CompositeSignature",
            "f_vsn": "1.0.0",
            "addr": "$ADDRESS_REPLACEMENT",
            "keyId": $KEY_ID_REPLACEMENT,
            "signature": "$SIGNATURE_REPLACEMENT"
          },
          "type": "FCL:VIEW:RESPONSE"
        }
    """
}

extension FCLScripts {
    private static func generateAuthnPreAuthz() async throws -> String {
        let payer = RemoteConfigManager.shared.payer
        
        if RemoteConfigManager.shared.freeGasEnabled {
            let keyId = try await FlowNetwork.getLastBlockAccountKeyId(address: payer)
            
            let str = """
                {
                    "f_type": "Service",
                    "f_vsn": "1.0.0",
                    "type": "pre-authz",
                    "uid": "fcw#pre-authz",
                    "endpoint": "ios://pre-authz.lilico.app",
                    "method": "EXT/RPC",
                    "data": {
                        "address": "\(payer)",
                        "keyId": \(keyId)
                    }
                },
            """
            
            return str
        } else {
            return ""
        }
    }
    
    private static func generateAuthnAccountProof(accountProofSign: String, address: String, nonce: String) -> String {
        let dict = [AddressReplacement: address, SignatureReplacement: accountProofSign, NonceReplacement: nonce]
        return FCLScripts.authnResponseAccountProof.replace(by: dict)
    }
}

extension FCLScripts {
    static func generatePreAuthzResponse(address: String) -> String {
        let dict = [AddressReplacement: address, PayerAddressReplacement: RemoteConfigManager.shared.payer]
        return FCLScripts.preAuthzResponse.replace(by: dict)
    }
    
    static func generateSignMessageResponse(message: String, address: String) -> String? {
        let data = Flow.DomainTag.user.normalize + Data(hex: message)
        guard let signedData = WalletManager.shared.signSync(signableData: data) else {
            return nil
        }
        
        let hex = signedData.hexString
        let dict = [AddressReplacement: address, SignatureReplacement: hex]
        return FCLScripts.signMessageResponse.replace(by: dict)
    }
    
    static func generateAuthnResponse(accountProofSign: String = "", nonce: String = "", address: String) async throws -> String {
        let authz = try await generateAuthnPreAuthz()
        
        var confirmedAccountProofSign = accountProofSign
        if !accountProofSign.isEmpty {
            confirmedAccountProofSign = generateAuthnAccountProof(accountProofSign: accountProofSign, address: address, nonce: nonce)
        }
        
        let dict = [AddressReplacement: address, PreAuthzReplacement: authz, UserSignatureReplacement: authnResponseUserSignature, AccountProofReplacement: confirmedAccountProofSign]
        return FCLScripts.authnResponse.replace(by: dict)
    }
    
    static func generateAuthzResponse(address: String, signature: String, keyId: Int = 0) -> String {
        let dict = [AddressReplacement: address, SignatureReplacement: signature, KeyIDReplacement: "\(keyId)"]
        return FCLScripts.authzResponse.replace(by: dict)
    }
}
