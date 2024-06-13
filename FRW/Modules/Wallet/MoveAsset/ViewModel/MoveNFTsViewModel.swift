//
//  MoveNFTsViewModel.swift
//  FRW
//
//  Created by cat on 2024/5/17.
//

import Foundation
import SwiftUI

class MoveNFTsViewModel: ObservableObject {
    @Published var selectedCollection: CollectionMask?
    private var collectionList: [CollectionMask] = []
    // NFTModel
    @Published var nfts: [MoveNFTsViewModel.NFT] = [
        MoveNFTsViewModel.NFT.mock(),
        MoveNFTsViewModel.NFT.mock(),
        MoveNFTsViewModel.NFT.mock()
    ]
    @Published var isMock = true
    @Published var showHint = false
    
    @Published var buttonState: VPrimaryButtonState = .disabled
    
    let limitCount = 10

    init() {
        fetchNFTs(0)
        
    }
    
    func moveAction() {
        guard let collection = selectedCollection else {
            return
        }
        buttonState = .loading
        Task {
            do {
                let address = collection.maskAddress
                let name = collection.maskContractName
                let ids: [UInt64] = nfts.compactMap { nft in
                    if !nft.isSelected {
                        return nil
                    }
                    let nftId = nft.model.maskId
                    guard let resultId = UInt64(nftId) else {
                        return nil
                    }
                    return resultId
                }
                let fromEvm = EVMAccountManager.shared.selectedAccount != nil
                let tid = try await FlowNetwork.bridgeNFTToEVM(contractAddress: address, contractName: name, ids: ids, fromEvm: fromEvm)
                let holder = TransactionManager.TransactionHolder(id: tid, type: .moveAsset)
                TransactionManager.shared.newTransaction(holder: holder)
                closeAction()
            }
            catch {
                log.error(" Move NFTs =====")
                log.error(error)
            }
        }
    }
    
    func selectCollectionAction() {
        
        let vm = SelectCollectionViewModel(selectedItem: selectedCollection, list: collectionList) { [weak self] item in
            DispatchQueue.main.async {
                self?.updateCollection(item: item)
            }
            
        }
        Router.route(to: RouteMap.NFT.selectCollection(vm))
    }
    
    private func updateCollection(item: CollectionMask) {
        if item.maskId == self.selectedCollection?.maskId, item.maskContractName == self.selectedCollection?.maskContractName {
            return
        }
        self.selectedCollection = item
        if EVMAccountManager.shared.selectedAccount == nil {
            self.nfts = []
            fetchNFTs()
        }else {
            self.nfts = []
            guard let col = self.selectedCollection as? EVMCollection else { return  }
            self.nfts = col.nfts.map { MoveNFTsViewModel.NFT(isSelected: false, model: $0) }
        }
    }
    
    func closeAction() {
        Router.dismiss {
            MoveAssetsAction.shared.endBrowser()
        }
    }
    
    func toggleSelection(of nft: MoveNFTsViewModel.NFT) {
        
        if let index = nfts.firstIndex(where: { $0.id == nft.id }) {
            if !nfts[index].isSelected && selectedCount >= limitCount {
                
            }else {
                nfts[index].isSelected.toggle()
            }
        }
        
        resetButtonState()
    }
    
    var selectedCount: Int {
        nfts.filter { $0.isSelected }.count
    }
    
    private func resetButtonState() {
        buttonState = selectedCount > 0 ? .enabled : .disabled
        showHint = selectedCount >= limitCount
    }
    
    var moveButtonTitle: String {
        if selectedCount > 0 {
            return "move_nft_x".localized(String(selectedCount))
        }
        return "move_nft".localized
    }
    
    private func fetchCollection() {
        Task {
            do {
                let address = WalletManager.shared.selectedAccountAddress
                let response: Network.Response<[NFTCollection]> = try await Network.requestWithRawModel(FRWAPI.NFT.userCollection(address, 0, 100))
                DispatchQueue.main.async {
                    self.collectionList = response.data?.sorted(by: { $0.count > $1.count }) ?? []
                    if self.selectedCollection == nil {
                        self.selectedCollection = self.collectionList.first
                    }
                    if self.selectedCollection != nil {
                        self.fetchFlowNFTs()
                    }else {
                        DispatchQueue.main.async {
                            self.nfts = []
                            self.isMock = false
                            self.resetButtonState()
                        }
                    }
                }
            }
            catch {
                log.error("[MoveAsset] fetch Collection failed:\(error)")
            }
        }
    }
    
    func fetchNFTs(_ offset: Int = 0) {
        if EVMAccountManager.shared.selectedAccount == nil {
            fetchFlowNFTs(offset)
        }else {
            fetchEVMNFTs()
        }
    }
    
    private func fetchFlowNFTs(_ offset: Int = 0) {
        buttonState = .loading
        guard let collection = selectedCollection else {
            fetchCollection()
            return
        }
        Task {
            do {
                let address = WalletManager.shared.selectedAccountAddress
                let request = NFTCollectionDetailListRequest(address: address, collectionIdentifier: collection.maskId, offset: offset, limit: 30)
                let response: NFTListResponse = try await Network.request(FRWAPI.NFT.collectionDetailList(request))
                DispatchQueue.main.async {
                    if let list = response.nfts {
                        self.nfts = list.map { MoveNFTsViewModel.NFT(isSelected: false, model: $0) }
                    }
                    else {
                        self.nfts = []
                    }
                    self.isMock = false
                    self.resetButtonState()
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.nfts = []
                    self.isMock = false
                    self.resetButtonState()
                }
                log.error("[MoveAsset] fetch NFTs failed:\(error)")
            }
        }
    }
    
    private func fetchEVMNFTs() {
        buttonState = .loading
        Task {
            do {
                guard let address = EVMAccountManager.shared.selectedAccount?.showAddress else {
                    DispatchQueue.main.async {
                        self.resetButtonState()
                    }
                    return
                }
                let response: [EVMCollection] =  try await Network.request(FRWAPI.EVM.nfts(address))
                DispatchQueue.main.async {
                    self.nfts = []
                    let sortedList = response.sorted(by: { $0.nfts.count > $1.nfts.count })
                    self.collectionList = sortedList
                    let collection = sortedList.first
                    self.selectedCollection = collection
                    self.nfts = collection?.nfts.map{ MoveNFTsViewModel.NFT(isSelected: false, model: $0) } ?? []
                    
                    self.isMock = false
                    self.resetButtonState()
                }
            }catch {
                DispatchQueue.main.async {
                    self.nfts = []
                    self.isMock = false
                    self.resetButtonState()
                }
                log.error("[MoveAsset] fetch EVM collection & NFTs failed:\(error)")
            }
        }
    }
}

extension MoveNFTsViewModel {
    private func emojiAccount(isFirst: Bool) -> WalletAccount.User {
        let address = accountAddress(isFirst: isFirst)
        return WalletManager.shared.walletAccount.readInfo(at: address)
    }
    
    func accountIcon(isFirst: Bool) -> some View {
        return emojiAccount(isFirst: isFirst).emoji.icon(size: 20)
    }
    
    func accountName(isFirst: Bool) -> String {
        return emojiAccount(isFirst: isFirst).name
    }
    
    func accountAddress(isFirst: Bool) -> String {
        let emvAddress = EVMAccountManager.shared.accounts.first?.showAddress ?? ""
        let flowAddress = WalletManager.shared.getPrimaryWalletAddress() ?? ""
        let address = showEVMTag(isFirst: isFirst) ? emvAddress : flowAddress
        return address
    }
    
    func showEVMTag(isFirst: Bool) -> Bool {
        let isSelectedEVM = EVMAccountManager.shared.selectedAccount != nil
        return isSelectedEVM == isFirst
    }
    
    func logo() -> Image {
        let isSelectedEVM = EVMAccountManager.shared.selectedAccount != nil
        return isSelectedEVM ? Image("icon_qr_evm") : Image("Flow")
    }
}

extension MoveNFTsViewModel {
    struct NFT: Identifiable {
        let id: UUID = .init()
        var isSelected: Bool
        var model: NFTMask
        
        var imageUrl: String {
            return model.maskLogo
        }
        
        static func mock() -> MoveNFTsViewModel.NFT {
            MoveNFTsViewModel.NFT(isSelected: false, model: NFTResponse.mock())
        }
    }
}

