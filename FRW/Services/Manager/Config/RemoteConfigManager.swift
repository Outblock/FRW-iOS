//
//  GasManager.swift
//  Flow Reference Wallet
//
//  Created by Selina on 5/9/2022.
//

import UIKit
import Flow
import SwiftUI

class RemoteConfigManager {
    static let shared = RemoteConfigManager()
    
    let emptyAddress = "0x0000000000000000"
    
    var config: Config?
    var contractAddress: ContractAddress?
    
    var isFailed: Bool = false
    
    var freeGasEnabled: Bool {
        return remoteGreeGas
//        if !remoteGreeGas {
//            return false
//        }
//        return localGreeGas
    }
    
    @AppStorage(LocalUserDefaults.Keys.freeGas.rawValue) private var localGreeGas = true
    private var remoteGreeGas: Bool {
        if let config = config {
            return config.features.freeGas
        }
        return false
    }
    
    var payer: String {
        if !freeGasEnabled {
            return WalletManager.shared.selectedAccountAddress
        }
        
        switch LocalUserDefaults.shared.flowNetwork.toFlowType() {
        case .mainnet:
            return config?.payer.mainnet.address ?? emptyAddress
        case .testnet:
            return config?.payer.testnet.address ?? emptyAddress
        case .crescendo:
            return config?.payer.crescendo?.address ?? emptyAddress
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
        case .crescendo:
            return config?.payer.crescendo?.keyID ?? 0
        default:
            return 0
        }
    }
    
    func getContarctAddress(_ network: LocalUserDefaults.FlowNetworkType) -> [String: String]? {
        switch network {
        case .mainnet:
            return contractAddress?.mainnet
        case .testnet:
            return contractAddress?.testnet
        case .crescendo:
            return contractAddress?.crescendo
        }
    }
    
    init() {
        do {
            let config: Config = try FirebaseConfig.config.fetch(decoder: JSONDecoder())
            self.config = config
            self.contractAddress = try FirebaseConfig.contractAddress.fetch(decoder: JSONDecoder())
        } catch {
            do {
                log.warning("will load from local")
                let config: Config = try FirebaseConfig.config.fetchLocal()
                self.config = config
                self.contractAddress = try FirebaseConfig.contractAddress.fetchLocal()
            } catch {
                self.isFailed = true
                log.error("load failed")
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
