//
//  ChildAccountManager.swift
//  Lilico
//
//  Created by Selina on 15/6/2023.
//

import SwiftUI
import Combine

struct ChildAccount: Codable {
    let address: String
    let name: String
    let desc: String
    let icon: String
    let pinTime: TimeInterval
    
    var isPinned: Bool {
        return pinTime > 0
    }
}

class ChildAccountManager: ObservableObject {
    static let shared = ChildAccountManager()
    
    @Published var childAccounts: [ChildAccount] = []
    
    var sortedChildAccounts: [ChildAccount] {
        return childAccounts.sorted { $0.pinTime > $1.pinTime }
    }
    
    private var cacheLoaded = false
    private var cancelSets = Set<AnyCancellable>()
    
    private init() {
        UserManager.shared.$activatedUID
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink { activatedUID in
                if activatedUID == nil {
                    self.clean()
                }
            }.store(in: &cancelSets)

        WalletManager.shared.$walletInfo
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink { walletInfo in
                if walletInfo != nil {
                    if !self.cacheLoaded {
                        self.loadCache()
                        return
                    }
                    
                    self.refresh()
                }
            }.store(in: &cancelSets)
        
        NotificationCenter.default.publisher(for: .networkChange)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.clean()
            }.store(in: &cancelSets)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willReset), name: .willResetWallet, object: nil)
    }
    
    @objc private func willReset() {
        childAccounts = []
    }
    
    private func loadCache() {
        if cacheLoaded {
            return
        }
        cacheLoaded = true
        
        guard let uid = UserManager.shared.activatedUID, let address = WalletManager.shared.getPrimaryWalletAddress() else {
            log.warning("uid or address is nil")
            return
        }
        
        childAccounts = MultiAccountStorage.shared.getChildAccounts(uid: uid, address: address) ?? []
    }
    
    private func clean() {
        log.debug("cleaned")
        childAccounts = []
    }
    
    func refresh() {
        guard let uid = UserManager.shared.activatedUID, let address = WalletManager.shared.getPrimaryWalletAddress() else {
            log.warning("uid or address is nil")
            return
        }
        
        log.debug("start refresh")
        
        Task {
            do {
                let list = try await FlowNetwork.queryChildAccountMeta(address)
                
                if UserManager.shared.activatedUID != uid { return }
                
                DispatchQueue.main.async {
                    let oldList = MultiAccountStorage.shared.getChildAccounts(uid: uid, address: address) ?? []
                    let finalList = list.map { newAccount in
                        if let oldAccount = oldList.first(where: { $0.address == newAccount.address }) {
                            return ChildAccount(address: newAccount.address, name: newAccount.name, desc: newAccount.desc, icon: newAccount.icon, pinTime: oldAccount.pinTime)
                        } else {
                            return newAccount
                        }
                    }
                    
                    self.childAccounts = finalList
                    self.saveToCache(finalList, uid: uid, address: address)
                }
            } catch {
                log.error("refresh failed", context: error)
            }
        }
    }
    
    private func saveToCache(_ childAccounts: [ChildAccount], uid: String, address: String) {
        do {
            try MultiAccountStorage.shared.saveChildAccounts(childAccounts, uid: uid, address: address)
        } catch {
            log.error("save to cache failed", context: error)
        }
    }
}

extension ChildAccountManager {
    func togglePinStatus(_ childAccount: ChildAccount) {
        var oldList = childAccounts
        guard let oldChildAccount = oldList.first(where: { $0.address == childAccount.address }) else {
            log.warning("child account is not exist")
            return
        }
        
        oldList.removeAll(where: { $0.address == childAccount.address })
        
        let newChildAccount = ChildAccount(address: oldChildAccount.address, name: oldChildAccount.name, desc: oldChildAccount.desc, icon: oldChildAccount.icon, pinTime: oldChildAccount.isPinned ? 0 : Date().timeIntervalSince1970)
        oldList.append(newChildAccount)
        
        childAccounts = oldList
        
        guard let uid = UserManager.shared.activatedUID, let address = WalletManager.shared.getPrimaryWalletAddress() else {
            log.error("uid or address is nil")
            return
        }
        
        saveToCache(oldList, uid: uid, address: address)
    }
    
    func didUnlinkAccount(_ childAccount: ChildAccount) {
        var oldList = childAccounts
        oldList.removeAll(where: { $0.address == childAccount.address })
        childAccounts = oldList
        
        guard let uid = UserManager.shared.activatedUID, let address = WalletManager.shared.getPrimaryWalletAddress() else {
            log.error("uid or address is nil")
            return
        }
        
        saveToCache(oldList, uid: uid, address: address)
    }
}
