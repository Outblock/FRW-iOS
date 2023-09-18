//
//  PayAsSigner.swift
//  Flow Reference Wallet
//
//  Created by Hao Fu on 8/9/2022.
//

import Foundation
import Flow

struct FCLVoucher: Codable {
    let cadence: Flow.Script
    let payer: Flow.Address
    let refBlock: Flow.ID
    let arguments: [Flow.Argument]
    let proposalKey: ProposalKey
    let computeLimit: UInt64
    let authorizers: [Flow.Address]
    let payloadSigs: [Signature]
    
    struct ProposalKey: Codable {
        let address: Flow.Address
        let keyId: Int
        let sequenceNum: UInt64
    }
    
    struct Signature: Codable {
        let address: Flow.Address
        let keyId: Int
        let sig: String
    }
}

struct SignPayerResponse: Codable {
    let envelopeSigs: FCLVoucher.Signature
}

struct SignPayerRequest: Codable {
    let transaction: FCLVoucher
    let message: PayerMessage
}

struct PayerMessage: Codable {
    let envelopeMessage: String
    
    enum CodingKeys: String, CodingKey {
        case envelopeMessage = "envelope_message"
    }
}


extension Flow.Transaction {
    var voucher: FCLVoucher {
        FCLVoucher(cadence: script,
                   payer: payer,
                   refBlock: referenceBlockId,
                   arguments: arguments,
                   proposalKey: FCLVoucher.ProposalKey(address: proposalKey.address,
                                                       keyId: proposalKey.keyIndex,
                                                       sequenceNum: UInt64(proposalKey.sequenceNumber)),
                   computeLimit: UInt64(gasLimit),
                   authorizers: authorizers,
                   payloadSigs: payloadSignatures.compactMap{
            FCLVoucher.Signature(address: $0.address,
                                 keyId: $0.keyIndex,
                                 sig: $0.signature.hexValue)
        })
    }
}
