//
//  DeveloperModeViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 15/9/2022.
//

import SwiftUI
import Combine
import Flow

class DeveloperModeViewModel: ObservableObject {
    @Published var customWatchAddress: String? = LocalUserDefaults.shared.customWatchAddress
    @Published var customAddressText: String = ""
    private(set) var demoAddress: String = "0x01d63aa89238a559"
    private(set) var svgDemoAddress: String = "0x95601dba5c2506eb"
    
    private var cancelable = Set<AnyCancellable>()
    
    init() {
        if let customWatchAddress = customWatchAddress, !customWatchAddress.isEmpty {
            customAddressText = customWatchAddress
        }
        
        NotificationCenter.default.publisher(for: .watchAddressDidChanged).sink { [weak self] _ in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                self.customWatchAddress = LocalUserDefaults.shared.customWatchAddress
                self.customAddressText = self.customWatchAddress ?? ""
            }
        }.store(in: &cancelable)
    }
}

extension DeveloperModeViewModel {
    var isCustomAddress: Bool {
        if let address = customWatchAddress, !address.trim().isEmpty {
            return true
        }
        
        return false
    }
    
    var isSVGDemoAddress: Bool {
        if let address = customWatchAddress, address == svgDemoAddress {
            return true
        }
        
        return false
    }
    
    var isDemoAddress: Bool {
        if let address = customWatchAddress, address == demoAddress {
            return true
        }
        
        return false
    }
    
    func changeCustomAddressAction(_ address: String) {
        if address.isEmpty {
            LocalUserDefaults.shared.customWatchAddress = nil
            return
        }
        
        LocalUserDefaults.shared.customWatchAddress = address
    }
    
    func enableCrescendoAction() {
        HUD.loading()
        
        let failedBlock = {
            DispatchQueue.main.async {
                HUD.dismissLoading()
                HUD.error(title: "enable_sandbox_failed".localized)
                FlowNetwork.setup()
            }
        }
        
        let successBlock = {
            DispatchQueue.main.async {
                HUD.dismissLoading()
                WalletManager.shared.changeNetwork(.crescendo)
            }
        }
        
        Task {
            do {
                
                let request = NetworkRequest(accountKey: AccountKey(hashAlgo: WalletManager.shared.hashAlgo.index, publicKey: WalletManager.shared.getCurrentPublicKey() ?? "", signAlgo: WalletManager.shared.signatureAlgo.index, weight: 1000), network: "crescendo")
                let id: String = try await Network.request(FRWAPI.User.crescendo(request))
                let txId = Flow.ID(hex: id)
                
                flow.configure(chainID: .crescendo)
                
                let result = try await txId.onceSealed()
                if result.isFailed {
                    failedBlock()
                    return
                }
                
                successBlock()
            } catch {
                debugPrint("DeveloperModeViewModel -> enableCrescendoAction failed: \(error)")
                failedBlock()
            }
        }
    }
    
    func enablePreviewnetAction() {
        HUD.loading()
        
        let failedBlock = {
            DispatchQueue.main.async {
                HUD.dismissLoading()
                HUD.error(title: "enable_previewnet_failed".localized)
                FlowNetwork.setup()
            }
        }
        
        let successBlock = {
            DispatchQueue.main.async {
                HUD.dismissLoading()
                WalletManager.shared.changeNetwork(.previewnet)
            }
        }
        
        Task {
            do {
                
                let request = NetworkRequest(accountKey: AccountKey(hashAlgo: WalletManager.shared.hashAlgo.index, publicKey: WalletManager.shared.getCurrentPublicKey() ?? "", signAlgo: WalletManager.shared.signatureAlgo.index, weight: 1000), network: "previewnet")
                let id: String = try await Network.request(FRWAPI.User.previewnet(request))
                let txId = Flow.ID(hex: id)
                flow.configure(chainID: LocalUserDefaults.FlowNetworkType.previewnet.toFlowType())

                let result = try await txId.onceSealed()
                if result.isFailed {
                    failedBlock()
                    return
                }
                successBlock()
            } catch {
                debugPrint("DeveloperModeViewModel -> enablePreviewnetAction failed: \(error)")
                failedBlock()
            }
        }
    }
}
