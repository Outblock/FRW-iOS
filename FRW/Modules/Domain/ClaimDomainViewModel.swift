//
//  ClaimDomainViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 16/9/2022.
//

import Flow
import SwiftUI

// MARK: - ClaimDomainViewModel

class ClaimDomainViewModel: ObservableObject {
    // MARK: Internal

    @Published
    var username: String? = UserManager.shared.userInfo?.username
    @Published
    var isRequesting: Bool = false

    func claimAction() {
        guard username != nil else {
            return
        }

        let successBlock: (String) -> Void = { txId in
            DispatchQueue.main.async {
                let holder = TransactionManager.TransactionHolder(
                    id: Flow.ID(hex: txId),
                    type: .claimDomain,
                    data: Data()
                )
                TransactionManager.shared.newTransaction(holder: holder)

                self.isRequesting = false
                Router.pop()
            }
        }

        let failureBlock = {
            DispatchQueue.main.async {
                self.isRequesting = false
                HUD.error(title: "claim_domain_failed".localized)
            }
        }

        isRequesting = true

        Task {
            do {
                let prepareResponse: ClaimDomainPrepareResponse = try await Network
                    .request(FRWAPI.Flowns.domainPrepare)
                let request = try await buildPayerSignableRequest(response: prepareResponse)
                let signatureResponse: ClaimDomainSignatureResponse = try await Network
                    .request(FRWAPI.Flowns.domainSignature(request))

                guard let txId = signatureResponse.txId, !txId.isEmpty else {
                    debugPrint("ClaimDomainViewModel -> claimAction txId is empty")
                    failureBlock()
                    return
                }

                if TransactionManager.shared.isExist(tid: txId) {
                    failureBlock()
                    return
                }

                successBlock(txId)
            } catch {
                debugPrint("ClaimDomainViewModel -> claimAction failed: \(error)")
                failureBlock()
            }
        }
    }

    // MARK: Private

    private func buildPayerSignableRequest(response: ClaimDomainPrepareResponse) async throws
        -> SignPayerRequest {
        let address = WalletManager.shared.getPrimaryWalletAddress() ?? ""
        let account = try await FlowNetwork.getAccountAtLatestBlock(address: address)

        var transaction = try await flow.buildTransaction {
            cadence {
                response.cadence ?? ""
            }

            arguments {
                [.string(username ?? "")]
            }

            gasLimit {
                9999
            }

            proposer {
                Flow.Address(hex: address)
            }

            authorizers {
                [
                    Flow.Address(hex: address),
                    Flow.Address(hex: response.lilicoServerAddress ?? ""),
                    Flow.Address(hex: response.flownsServerAddress ?? ""),
                ]
            }

            payer {
                RemoteConfigManager.shared.payer
            }
        }

        let signedTransaction = try await transaction
            .signPayload(signers: WalletManager.shared.defaultSigners)

        return signedTransaction.buildSignPayerRequest()
    }
}

extension Flow.Transaction {
    func buildSignPayerRequest() -> SignPayerRequest {
        let pKey = FCLVoucher.ProposalKey(
            address: proposalKey.address,
            keyId: proposalKey.keyIndex,
            sequenceNum: UInt64(proposalKey.sequenceNumber)
        )
        let payloadSigs = payloadSignatures.map { FCLVoucher.Signature(
            address: $0.address,
            keyId: $0.keyIndex,
            sig: $0.signature.hexValue
        ) }

        let voucher = FCLVoucher(
            cadence: script,
            payer: payer,
            refBlock: referenceBlockId,
            arguments: arguments,
            proposalKey: pKey,
            computeLimit: UInt64(gasLimit),
            authorizers: authorizers,
            payloadSigs: payloadSigs
        )

        let msg = signablePlayload?.hexValue ?? ""
        let request = SignPayerRequest(
            transaction: voucher,
            message: PayerMessage(envelopeMessage: msg)
        )

        return request
    }
}
