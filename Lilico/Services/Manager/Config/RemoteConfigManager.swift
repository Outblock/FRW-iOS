//
//  GasManager.swift
//  Lilico
//
//  Created by Selina on 5/9/2022.
//

import UIKit
import Flow

class RemoteConfigManager {
    static let shared = RemoteConfigManager()
    
    let emptyAddress = "0x0000000000000000"
    
    var config: Config?
    
    var isFailed: Bool = false
    
    var freeGasEnabled: Bool {
        if let config = config {
            return config.features.freeGas
        }
        
        return false
    }
    
    var payer: String {
        if !freeGasEnabled {
            return emptyAddress
        }
        
        switch LocalUserDefaults.shared.flowNetwork.toFlowType() {
        case .mainnet:
            return config?.payer.mainnet.address ?? emptyAddress
        case .testnet:
            return config?.payer.testnet.address ?? emptyAddress
        case .sandboxnet:
            return config?.payer.sandboxnet.address ?? emptyAddress
        default:
            return emptyAddress
        }
    }
    
    var payerKeyId: Int {
        if !freeGasEnabled {
            return 0
        }
        
        switch LocalUserDefaults.shared.flowNetwork.toFlowType() {
        case .mainnet:
            return config?.payer.mainnet.keyID ?? 0
        case .testnet:
            return config?.payer.testnet.keyID ?? 0
        case .sandboxnet:
            return config?.payer.sandboxnet.keyID ?? 0
        default:
            return 0
        }
    }
    
    init() {
        Task {
            do {
                let config: Config = try await FirebaseConfig.config.fetch(decoder: JSONDecoder())
                self.config = config
            } catch {
                do {
                    let config: Config = try await FirebaseConfig.config.fetchLocal()
                    self.config = config
                } catch {
                    self.isFailed = true
                }
            }
        }
    }
}

extension RemoteConfigManager: FlowSigner {
    
    var address: Flow.Address {
        .init(hex: payer)
    }
    
    var hashAlgo: Flow.HashAlgorithm {
        .SHA2_256
    }
    
    var signatureAlgo: Flow.SignatureAlgorithm {
        .ECDSA_P256
    }
    
    var keyIndex: Int {
        payerKeyId
    }
    
    func sign(transaction: Flow.Transaction, signableData: Data) async throws -> Data {
        let request = SignPayerRequest(transaction: transaction.voucher, message: .init(envelopeMessage: signableData.hexValue))
        let signature:SignPayerResponse = try await Network.requestWithRawModel(FirebaseAPI.signAsPayer(request))
        return Data(hex: signature.envelopeSigs.sig)
    }
    
    func sign(voucher: FCLVoucher, signableData: Data) async throws -> Data {
        let request = SignPayerRequest(transaction: voucher, message: .init(envelopeMessage: signableData.hexValue))
        let signature:SignPayerResponse = try await Network.requestWithRawModel(FirebaseAPI.signAsPayer(request))
        return Data(hex: signature.envelopeSigs.sig)
    }
}
