//
//  MoveSingleNFTViewModel.swift
//  FRW
//
//  Created by cat on 2024/5/22.
//

import Foundation
import SwiftUI
import Flow

class MoveSingleNFTViewModel: ObservableObject {
    var nft: NFTModel
    var fromChildAccount: ChildAccount?
    var callback: ()->()
    
    @Published var fromContact: Contact = Contact(address: "", avatar: "", contactName: "", contactType: nil, domain: nil, id: -1, username: nil)
    @Published var toContact: Contact = Contact(address: "", avatar: "", contactName: "", contactType: nil, domain: nil, id: -1, username: nil)
    @Published var buttonState: VPrimaryButtonState = .enabled
    
    var accountCount: Int = 0
    
    init(nft: NFTModel, fromChildAccount: ChildAccount? = nil, callback: @escaping ()->()) {
        self.nft = nft
        self.fromChildAccount = fromChildAccount
        self.callback = callback
        loadUserInfo()
        
        let accountViewModel = MoveAccountsViewModel(selected: "") { contact in }
        self.accountCount = accountViewModel.list.count
    }
    
    private func loadUserInfo() {
        guard let primaryAddr = WalletManager.shared.getPrimaryWalletAddressOrCustomWatchAddress() else {
            return
        }
        if let account = self.fromChildAccount {
            fromContact = Contact(address: account.showAddress, avatar: account.icon, contactName: nil, contactType: .user, domain: nil, id: UUID().hashValue, username: account.showName,walletType: .link)
        }else if let account = ChildAccountManager.shared.selectedChildAccount {
            fromContact = Contact(address: account.showAddress, avatar: account.icon, contactName: nil, contactType: .user, domain: nil, id: UUID().hashValue, username: account.showName,walletType: .link)
        }else if let account = EVMAccountManager.shared.selectedAccount {
            let user = WalletManager.shared.walletAccount.readInfo(at: account.showAddress)
            fromContact = Contact(address: account.showAddress, avatar: nil, contactName: nil, contactType: .user, domain: nil, id: UUID().hashValue, username: account.showName,user: user,walletType: .evm)
        }else  {
            let user = WalletManager.shared.walletAccount.readInfo(at: primaryAddr)
            fromContact = Contact(address: primaryAddr, avatar: nil, contactName: nil, contactType: .user, domain: nil, id: UUID().hashValue, username: user.name, user: user,walletType: .flow)
        }
        
        
        if ChildAccountManager.shared.selectedChildAccount != nil || EVMAccountManager.shared.selectedAccount != nil || fromChildAccount != nil  {
            let user = WalletManager.shared.walletAccount.readInfo(at: primaryAddr)
            toContact = Contact(address: primaryAddr, avatar: nil, contactName: nil, contactType: .user, domain: nil, id: UUID().hashValue, username: user.name,user: user ,walletType: .flow)
        }else if let account = EVMAccountManager.shared.accounts.first {
            let user = WalletManager.shared.walletAccount.readInfo(at: account.showAddress)
            toContact = Contact(address: account.showAddress, avatar: nil, contactName: nil, contactType: .user, domain: nil, id: UUID().hashValue, username: account.showName,user: user, walletType: .evm)
        }else if let account = ChildAccountManager.shared.childAccounts.first {
            toContact = Contact(address: account.showAddress, avatar: account.icon, contactName: nil, contactType: .user, domain: nil, id: UUID().hashValue, username: account.showName,walletType: .link)
        }
    }
    
    func closeAction() {
        Router.dismiss()
        callback()
    }
    
    func moveAction() {
        guard let nftId = UInt64(nft.response.id),
              let address = nft.response.contractAddress,
              let name = nft.response.collectionContractName else {
            HUD.error(title: "invalid data")
            return
        }
        buttonState = .loading
        Task {
            if fromContact.walletType == .link || toContact.walletType == .link {
                await moveForLinkedAccount(nftId: nftId)
            }else {
                await moveForEVM(nftId: nftId, address: address, name: name)
            }
            DispatchQueue.main.async {
                self.buttonState = .enabled
            }
        }
    }
    
    private func moveForEVM(nftId: UInt64, address: String, name: String) async {
        do {
            
            let ids: [UInt64] = [nftId]
            let fromEvm = EVMAccountManager.shared.selectedAccount != nil
            let tid = try await FlowNetwork.bridgeNFTToEVM(contractAddress: address, contractName: name, ids: ids, fromEvm: fromEvm)
            let holder = TransactionManager.TransactionHolder(id: tid, type: .moveAsset)
            TransactionManager.shared.newTransaction(holder: holder)
            closeAction()
        }
        catch {
            log.error(" Move NFT =====")
            log.error(error)
        }
    }
    
    private func moveForLinkedAccount(nftId: UInt64) async {
        guard let collection = nft.collection else {
            return
        }
        let identifier = nft.publicIdentifier
        do {
            var tid = Flow.ID(hex: "")
            switch (fromContact.walletType, toContact.walletType) {
            case (.flow, .link):
                tid = try await FlowNetwork.moveNFTToChild(nftId: nftId, childAddress: toContact.address ?? "", identifier: identifier, collection: collection)
            case (.link, .flow):
                tid = try await FlowNetwork.moveNFTToParent(nftId: nftId, childAddress: fromContact.address ?? "", identifier: identifier, collection: collection)
            case (.link, .link):
                tid = try await FlowNetwork.sendChildNFTToChild(nftId: nftId, childAddress: fromContact.address ?? "", toAddress: toContact.address ?? "", identifier: identifier, collection: collection)
            default:
                log.info("===")
            }
            let holder = TransactionManager.TransactionHolder(id: tid, type: .moveAsset)
            TransactionManager.shared.newTransaction(holder: holder)
            closeAction()
        }
        catch {
            log.error("[Move NFT] Move NFT failed on Linked Account. ")
            log.error(error)
        }
    }
    
    func updateToContact(_ contact: Contact) {
        self.toContact = contact
    }
}

extension MoveSingleNFTViewModel {
    
    var fromIsEVM: Bool {
        EVMAccountManager.shared.accounts.contains { $0.showAddress == fromContact.address }
    }
    
    var toIsEVM: Bool {
        EVMAccountManager.shared.accounts.contains { $0.showAddress == toContact.address }
    }
    
   

    
    func logo() -> Image {
        let isSelectedEVM = EVMAccountManager.shared.selectedAccount != nil
        return isSelectedEVM ? Image("icon_qr_evm") : Image("Flow")
    }
}
