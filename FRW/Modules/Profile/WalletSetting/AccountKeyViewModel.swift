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
    
    init() {
        let model = Flow.AccountKey(publicKey: Flow.PublicKey(hex: "abc"), signAlgo: .ECDSA_P256, hashAlgo: .SHA2_256, weight: 1000)
        allKeys = [AccountKeyModel(accountKey: model),AccountKeyModel(accountKey: model),AccountKeyModel(accountKey: model)]
        fetch()
    }
    
    func fetch()  {
        Task {
            do {
                DispatchQueue.main.async {
                    self.status = .loading
                }
                let address = WalletManager.shared.getPrimaryWalletAddress() ?? ""
                let account = try await FlowNetwork.getAccountAtLatestBlock(address: address)
                DispatchQueue.main.async {
                    self.allKeys = account.keys.map { AccountKeyModel(accountKey: $0) }
                    self.status = self.allKeys.count == 0 ? .empty : .finished
                }
                
            } catch {
                status = .error
            }
        }
    }
}

struct AccountKeyModel {
    
    enum ContentType: Int {
        case publicKey,curve,hash,number
    }
    
    let accountKey: Flow.AccountKey
    var expanding: Bool = false
    
    init(accountKey: Flow.AccountKey) {
        self.accountKey = accountKey
    }
    
    func deviceName() -> String {
        
        if accountKey.revoked {
            return "Revoked"
        }
        
        if isCurrent() {
            return "Current Device"
        }
        
        //TODO: #six
        return ""
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
        let res = 72.0 - Double(accountKey.weight)/1000.0 * 72.0
        return min(72.0, res)
    }
    
    func weightBG() -> Color {
       return accountKey.weight >= 1000
        ? Color.Theme.Accent.green
        : Color.Theme.Text.black3
    }
}
