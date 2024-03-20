//
//  EVMAccountManager.swift
//  FRW
//
//  Created by cat on 2024/3/19.
//

import Foundation
import Combine
import SwiftUI

class EVMAccountManager: ObservableObject {
    static let shared = EVMAccountManager()
    
    @Published var hasAccount: Bool = false
    @Published var accounts: [EVMAccountManager.Account] = [] {
        didSet {
//            validSelectedChildAccount()
        }
    }
    
    private var cancelSets = Set<AnyCancellable>()
    
    @Published var selectedAccount: EVMAccountManager.Account? = LocalUserDefaults.shared.selectedEVMAccount {
        didSet {
            LocalUserDefaults.shared.selectedEVMAccount = selectedAccount
        }
    }
    
    init() {
        refresh()
        
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
//                    if !self.cacheLoaded {
//                        self.loadCache()
//                        return
//                    }
                    
                    self.refresh()
                }
            }.store(in: &cancelSets)
        
        NotificationCenter.default.publisher(for: .networkChange)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.clean()
            }.store(in: &cancelSets)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willReset), name: .willResetWallet, object: nil)
        
        NotificationCenter.default.publisher(for: .transactionStatusDidChanged)
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink { [weak self] noti in
                self?.onTransactionStatusChanged(noti)
            }.store(in: &cancelSets)
    }
    
    private func clean() {
        log.debug("cleaned")
        accounts = []
    }
    
    @objc private func willReset() {
        clean()
    }
    
    @objc private func onTransactionStatusChanged(_ noti: Notification) {
        guard let obj = noti.object as? TransactionManager.TransactionHolder, obj.type == .editChildAccount else {
            return
        }
        
        switch obj.internalStatus {
        case .success:
            refresh()
        default:
            break
        }
    }
}

extension EVMAccountManager {
    func refresh() {
        Task {
            do {
                let address = try await fetchAddress()
                if let address = address, !address.isEmpty {
                    let balance = try await fetchBalance(address)
                    DispatchQueue.main.async {
                        let account = EVMAccountManager.Account(address: address, balance: balance)
                        self.accounts = []
                        self.accounts.append(account)
                        self.hasAccount = true
                    }
                }else {
                    DispatchQueue.main.async {
                        self.accounts = []
                        self.hasAccount = false
                    }
                }
            }
            catch {
                log.error("[EVM] get address failed.\(error)")
            }
        }
    }
    
    func select(_ account: EVMAccountManager.Account?){
        if selectedAccount?.address == account?.address {
            return
        }
        selectedAccount = account
    }
}

extension EVMAccountManager {
    func enableEVM() async throws {
        let tid = try await FlowNetwork.createEVM()
        let result = try await tid.onceSealed()
        if result.isFailed {
            log.error("[EVM] create EVM result: Failed")
            throw EVMError.createAccount
        }
    }
    
    func fetchAddress() async throws -> String? {
        let address = try await FlowNetwork.findEVMAddress()
        return address
    }
    
    func fetchBalance(_ address: String) async throws -> UInt {
        return try await FlowNetwork.fetchEVMBalance(address: address)
    }
}

extension EVMAccountManager {
    struct Account: ChildAccountSideCellItem, Codable {
        var address: String
        var balance: UInt = 0
        
        var showAddress: String {
            if address.hasPrefix("0x") {
                return address
            }
            return "0x" + address
        }
        
        var showIcon: String {
            "https://firebasestorage.googleapis.com/v0/b/lilico-334404.appspot.com/o/asset%2Feth.png?alt=media&token=1b926945-5459-4aee-b8ef-188a9b4acade"
        }
        
        var showName: String {
            "Flow-EVM Wallet"
        }
        
        var isEVM: Bool {
            true
        }
        
        var isSelected: Bool {
            if let selectedAccount = EVMAccountManager.shared.selectedAccount,
               selectedAccount.address == address, !address.isEmpty {
                return true
            }
            return false
        }
        
    }
}
