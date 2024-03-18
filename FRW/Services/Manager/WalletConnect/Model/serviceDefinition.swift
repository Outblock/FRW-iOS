//
//  ServiceDef.swift
//  Flow Wallet
//
//  Created by Hao Fu on 30/7/2022.
//

import Foundation


func serviceDefinition(address: String, keyId: Int, type: FCLServiceType) -> Service {
    
    var service = Service(fType: "Service",
                          fVsn: "1.0.0",
                          type: type,
                          method: .walletConnect,
                          endpoint: nil,
                          uid: "https://link.lilico.app/wc",
                          id: nil,
                          identity: Identity(address: address, keyId: keyId),
                          provider: nil, params: nil, data: nil)
    
    if type == .authn {
        service.id = address
        service.provider = Provider(fType: "ServiceProvider",
                                    fVsn: "1.0.0",
                                    address: address,
                                    name: "Lilico Wallet",
                                    description: "A Mobile crypto wallet on Flow built for explorers, collectors, and gamers.",
                                    color: "#FC814A",
                                    supportEmail: "hi@lilico.app",
                                    website: "https://link.lilico.app/wc")
        
    }
    service.endpoint = FCLWalletConnectMethod(type: type)?.rawValue
    return service
}

//{
//    "f_type": "Service",
//    "f_vsn": "1.0.0",
//    "type": "account-proof",
//    "uid": "lilico#account-proof",
//    "endpoint": "chrome-extension://hpclkefagolihohboafpheddmmgdffjm/popup.html",
//    "method": "EXT/RPC",
//    "data": {
//      "f_type": "account-proof",
//      "f_vsn": "2.0.0",
//      "address": "$ADDRESS_REPLACEMENT",
//      "nonce": "$NONCE_REPLACEMENT",
//      "signatures": [
//        {
//          "f_type": "CompositeSignature",
//          "f_vsn": "1.0.0",
//          "addr": "$ADDRESS_REPLACEMENT",
//          "keyId": 0,
//          "signature": "$SIGNATURE_REPLACEMENT"
//        }
//      ]
//    }
//},


func accountProofServiceDefinition(address: String, keyId: Int, nonce: String, signature: String) -> Service {
    
    var service = Service(fType: "Service",
                          fVsn: "1.0.0",
                          type: FCLServiceType.accountProof,
                          method: .walletConnect,
                          endpoint: nil,
                          uid: "https://link.lilico.app/wc",
                          id: nil,
                          identity: nil,
                          provider: nil,
                          params: nil,
                          data: nil)
    
    
    service.data = AccountProof(fType: FCLServiceType.accountProof.rawValue,
                         fVsn: "2.0.0",
                         address: address,
                         nonce: nonce,
                         signatures: [AccountProofSignature(fType: "CompositeSignature",
                                                            fVsn: "1.0.0",
                                                            addr: address,
                                                            keyID: keyId,
                                                            signature: signature)] )
    
    service.endpoint = FCLWalletConnectMethod(type: FCLServiceType.accountProof)?.rawValue
    return service
}
