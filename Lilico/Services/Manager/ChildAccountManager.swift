//
//  ChildAccountManager.swift
//  Lilico
//
//  Created by Selina on 15/6/2023.
//

import SwiftUI
import Combine

struct ChildAccount: Codable {
    var addr: String
    let name: String?
    var aName: String {
        return name ?? "Linked Account"
    }
    
    let description: String?
    let thumbnail: Thumbnail?
    var icon: String {
        thumbnail?.url ?? "https://lilico.app/placeholder.png"
    }

    var time: TimeInterval?
    var pinTime: TimeInterval {
        time ?? 0
    }

    var isPinned: Bool {
        return pinTime > 0
    }

    struct Thumbnail: Codable {
        let url: String?
    }

    init(address: String, name: String?, desc: String?, icon: String?, pinTime: TimeInterval) {
        self.addr = address
        self.name = name
        self.description = desc
        self.thumbnail = Thumbnail(url: icon)
        self.time = pinTime
    }
    
    var isSelected: Bool {
        if let selectedChildAccount = ChildAccountManager.shared.selectedChildAccount, selectedChildAccount.addr == addr, !addr.isEmpty {
            return true
        }
        
        return false
    }
}

class ChildAccountManager: ObservableObject {
    static let shared = ChildAccountManager()
    
    @Published var childAccounts: [ChildAccount] = [] {
        didSet {
            self.validSelectedChildAccount()
        }
    }
    @Published var selectedChildAccount: ChildAccount? = LocalUserDefaults.shared.selectedChildAccount {
        didSet {
            LocalUserDefaults.shared.selectedChildAccount = selectedChildAccount
        }
    }
    
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
            clean()
            return
        }
        
        let network = LocalUserDefaults.shared.flowNetwork
        
        log.debug("start refresh")
        
        Task {
            do {
                let list = try await FlowNetwork.queryChildAccountMeta(address)
                
                DispatchQueue.main.async {
                    if UserManager.shared.activatedUID != uid { return }
                    if LocalUserDefaults.shared.flowNetwork != network { return }
                    
                    let oldList = MultiAccountStorage.shared.getChildAccounts(uid: uid, address: address) ?? []
                    let finalList = list.map { newAccount in
                        if let oldAccount = oldList.first(where: { $0.addr == newAccount.addr }) {
                            return ChildAccount(address: newAccount.addr, name: newAccount.name, desc: newAccount.description, icon: newAccount.icon, pinTime: oldAccount.pinTime)
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
    
    private func validSelectedChildAccount() {
        guard let selectedChildAccount = selectedChildAccount else {
            return
        }
        
        if childAccounts.contains(where: { $0.addr == selectedChildAccount.addr }) == false {
            self.selectedChildAccount = nil
        }
    }
}

extension ChildAccountManager {
    func togglePinStatus(_ childAccount: ChildAccount) {
        var oldList = childAccounts
        guard let oldChildAccount = oldList.first(where: { $0.addr == childAccount.addr }) else {
            log.warning("child account is not exist")
            return
        }
        
        oldList.removeAll(where: { $0.addr == childAccount.addr })
        
        let newChildAccount = ChildAccount(address: oldChildAccount.addr, name: oldChildAccount.name, desc: oldChildAccount.description, icon: oldChildAccount.icon, pinTime: oldChildAccount.isPinned ? 0 : Date().timeIntervalSince1970)
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
        oldList.removeAll(where: { $0.addr == childAccount.addr })
        childAccounts = oldList
        
        guard let uid = UserManager.shared.activatedUID, let address = WalletManager.shared.getPrimaryWalletAddress() else {
            log.error("uid or address is nil")
            return
        }
        
        saveToCache(oldList, uid: uid, address: address)
    }
    
    func select(_ childAccount: ChildAccount?) {
        if selectedChildAccount?.addr == childAccount?.addr {
            return
        }
        
        selectedChildAccount = childAccount
    }
}
