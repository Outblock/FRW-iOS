//
//  AccountKeyViewModel.swift
//  FRW
//
//  Created by cat on 2023/10/20.
//

import SwiftUI
import Flow

class AccountKeyViewModel: ObservableObject {
    @Published var allKeys: [AccountKeyModel] = []
    @Published var status: PageStatus = .loading
    
    @Published var showRovekeView = false
    var revokeModel: AccountKeyModel?
    
    init() {
        addMock()
        fetch()
    }
    
    func addMock() {
        let model = Flow.AccountKey(publicKey: Flow.PublicKey(hex: "test"), signAlgo: .ECDSA_P256, hashAlgo: .SHA2_256, weight: 1000)
        allKeys = [AccountKeyModel(accountKey: model)]
    }
    
    func fetch()  {
        Task {
            do {
                DispatchQueue.main.async {
                    self.status = .loading
                }
                let address = WalletManager.shared.getPrimaryWalletAddress() ?? ""
                let account = try await FlowNetwork.getAccountAtLatestBlock(address: address)
                let devices: KeyResponse = try await Network.request(FRWAPI.User.keys)
                DispatchQueue.main.async {
                    self.allKeys = account.keys.map { AccountKeyModel(accountKey: $0) }
                    self.allKeys = self.allKeys.map({ model in
                        var model = model
                        let result = devices.result ?? []
                        let devicesInfo = result.first { response in
                            response.pubkey.publicKey == model.accountKey.publicKey.description
                        }
                        if let info = devicesInfo {
                            model.name = info.device.deviceName ?? ""
                        }
                        return model;
                    })
                    self.status = self.allKeys.count == 0 ? .empty : .finished
                }
                
            } catch {
                allKeys = []
                status = .error
            }
        }
    }
    
    
    func revokeKey(at model: AccountKeyModel) {
        
        
        if showRovekeView {
            showRovekeView = false
        }
        self.revokeModel = model
        withAnimation(.easeOut(duration: 0.2)) {
            showRovekeView = true
        }
    }
    
    func revokeKeyAction() {
        Task {
            guard let address = WalletManager.shared.getPrimaryWalletAddress(), let model = self.revokeModel else {
                HUD.info(title: "account_key_fail_tips".localized)
                return
            }
            do {
                let flowId = try await FlowNetwork.revokeAccountKey(by: model.accountKey.index, at: Flow.Address(hex: address))
                DispatchQueue.main.async {
                    self.showRovekeView = false
                }
                log.debug("revoke flow id:\(flowId)")
                fetch()
            }catch {
                HUD.error(title: "account_key_fail_tips".localized)
                log.error("revoke key: \(error)")
            }
        }
    }
    
    func cancelRevoke() {
        DispatchQueue.main.async {
            self.revokeModel = nil
            self.showRovekeView = false
        }
    }
}

struct AccountKeyModel {
    
    enum ContentType: Int {
        case publicKey,curve,hash,number
    }
    
    let accountKey: Flow.AccountKey
    var expanding: Bool = false
    var name: String = ""
    
    init(accountKey: Flow.AccountKey) {
        self.accountKey = accountKey
    }
    
    func deviceName() -> String {
        
        if accountKey.revoked {
            return "revoked".localized
        }
        //TODO: #six revoking
        if isCurrent() {
            return "current_device".localized
        }
        return name
    }
    
    func deviceStyle() -> (Color, Color) {
        if accountKey.revoked {
            return (Color.Theme.Accent.red, Color.Theme.Accent.red.opacity(0.16))
        }
        
        if isCurrent() {
            return (Color.Theme.Accent.blue, Color.Theme.Accent.blue.opacity(0.16))
        }
        
        return (Color.Theme.Text.black3, Color.Theme.Text.black3.opacity(0.16))
    }
    
    
    func isCurrent() -> Bool {
        guard let cur = WalletManager.shared.getCurrentPublicKey() else {
            return false
        }
        
        return cur == accountKey.publicKey.description
    }
    
    
    func icon(at type: ContentType) -> Image {
        return Image("key.icon.\(type.rawValue)")
    }
    
    func tag(at type: ContentType) -> String {
        switch type {
        case .publicKey:
            return "account_key_key".localized
        case .curve:
            return "account_key_curve".localized
        case .hash:
            return "account_key_hash".localized
        case .number:
            return "account_key_number".localized
        }
    }
    
    func content(at type: ContentType) -> String {
        switch type {
        case .publicKey:
            accountKey.publicKey.description
        case .curve:
            accountKey.signAlgo.rawValue
        case .hash:
            accountKey.hashAlgo.rawValue
        case .number:
            String(accountKey.sequenceNumber)
        }
    }

    func weightDes() -> String {
        return "\(accountKey.weight)/1000"
    }
    
    func weightPadding() -> Double {
        let res = Double(accountKey.weight)/1000.0 * 72.0
        return min(72.0, res)
    }
    
    func weightBG() -> Color {
       return accountKey.weight >= 1000
        ? Color.Theme.Accent.green
        : Color.Theme.Text.black3
    }
}
