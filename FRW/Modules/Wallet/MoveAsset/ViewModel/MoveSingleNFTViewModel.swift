//
//  MoveSingleNFTViewModel.swift
//  FRW
//
//  Created by cat on 2024/5/22.
//

import Foundation
import SwiftUI

class MoveSingleNFTViewModel: ObservableObject {
    var nft: NFTModel
    
    var callback: ()->()
    
    init(nft: NFTModel, callback: @escaping ()->()) {
        self.nft = nft
        self.callback = callback
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
        Task {
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
    }
}

extension MoveSingleNFTViewModel {
    var showFromIcon: String {
        fromEVM ? evmIcon : walletIcon
    }

    var showFromName: String {
        fromEVM ? evmName : walletName
    }

    var showFromAddress: String {
        fromEVM ? evmAddress : walletAddress
    }
    
    var showToIcon: String {
        fromEVM ? walletIcon : evmIcon
    }
    
    var showToName: String {
        fromEVM ? walletName : evmName
    }
    
    var showToAddress: String {
        fromEVM ? walletAddress : evmAddress
    }
    
    var fromEVM: Bool {
        WalletManager.shared.isSelectedEVMAccount
    }
    
    private var walletIcon: String {
        UserManager.shared.userInfo?.avatar.convertedAvatarString() ?? ""
    }
    
    private var walletName: String {
        if let walletInfo = WalletManager.shared.walletInfo?.currentNetworkWalletModel {
            return walletInfo.getName ?? "wallet".localized
        }
        return "wallet".localized
    }
    
    private var walletAddress: String {
        if let walletInfo = WalletManager.shared.walletInfo?.currentNetworkWalletModel {
            return walletInfo.getAddress ?? "0x"
        }
        return "0x"
    }
    
    private var evmIcon: String {
        return EVMAccountManager.shared.accounts.first?.showIcon ?? ""
    }
    
    private var evmName: String {
        return EVMAccountManager.shared.accounts.first?.showName ?? ""
    }
    
    private var evmAddress: String {
        return EVMAccountManager.shared.accounts.first?.showAddress ?? ""
    }
    
    func logo() -> Image {
        let isSelectedEVM = EVMAccountManager.shared.selectedAccount != nil
        return isSelectedEVM ? Image("icon_qr_evm") : Image("Flow")
    }
}
