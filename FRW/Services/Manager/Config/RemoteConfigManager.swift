//
//  GasManager.swift
//  Flow Wallet
//
//  Created by Selina on 5/9/2022.
//

import UIKit
import Flow
import SwiftUI
import CryptoKit
import WalletCore

class RemoteConfigManager {
    static let shared = RemoteConfigManager()
    
    let emptyAddress = "0x0000000000000000"
    
    private var EVNConfig: ENVConfig?
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
        case .previewnet:
            return config?.payer.previewnet?.address ?? emptyAddress
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
        case .previewnet:
            return config?.payer.previewnet?.keyID ?? 0
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
        case .previewnet:
            return contractAddress?.previewnet
        }
    }
    
    init() {
        fetchNews()
        do {
            let data: String = try FirebaseConfig.ENVConfig.fetch()
            let key = LocalEnvManager.shared.backupAESKey
            if let keyData = key.data(using: .utf8),
               let ivData = key.sha256().prefix(16).data(using: .utf8) {
                
                let decodeData = AES.decryptCBC(key: keyData, data: Data(hex: data), iv: ivData, mode: .pkcs7)!
                let config = try? JSONDecoder().decode(ENVConfig.self, from: decodeData)
                self.EVNConfig = config
                self.config = nil
                if  let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                    let version = EVNConfig?.version
                {
                    if version.compareVersion(to: currentVersion) == .orderedDescending {
                        self.config = self.EVNConfig?.prod
                    }
                }
                
                if self.config == nil {
                    self.config = self.EVNConfig?.staging
                }
            } else {
                try loadLocalConfig()
            }
            self.contractAddress = try FirebaseConfig.contractAddress.fetch(decoder: JSONDecoder())
            
            NotificationCenter.default.post(name: .remoteConfigDidUpdate, object: nil)
//            try handleSecret()
        } catch {
            do {
                log.warning("will load from local")
                try loadLocalConfig()
            } catch {
                self.isFailed = true
                log.error("load failed")
            }
        }
    }
    
    private func fetchNews() {
        Task {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let list: [RemoteConfigManager.News] = try FirebaseConfig.news.fetch(decoder: decoder)
                WalletNewsHandler.shared.addRemoteNews(list)
            }
            catch {
                log.error("[Firebase] fetch news failed. \(error)")
            }
        }
    }
    
    private func loadLocalConfig() throws {
        let config: Config = try FirebaseConfig.ENVConfig.fetchLocal()
        self.config = config
        self.contractAddress = try FirebaseConfig.contractAddress.fetchLocal()
    }
    
    private func handleSecret() throws {
        let data: String = try FirebaseConfig.appSecret.fetch()
        let key = LocalEnvManager.shared.backupAESKey
        guard let keyData = key.data(using: .utf8),
              let ivData = key.sha256().prefix(16).data(using: .utf8) else{
            return
        }
        let decodeData = AES.decryptCBC(key: keyData, data: Data(hex: data), iv: ivData, mode: .pkcs7)!
        let config = try? JSONDecoder().decode(Config.self, from: decodeData)
        if config != nil {
            self.config = config
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


