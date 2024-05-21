//
//  MoveNFTsViewModel.swift
//  FRW
//
//  Created by cat on 2024/5/17.
//

import Foundation
import SwiftUI

class MoveNFTsViewModel: ObservableObject {
    @Published var selectedCollection: NFTCollection?
    private var collectionList: [NFTCollection] = []
    // NFTModel
    @Published var nfts: [MoveNFTsViewModel.NFT] = [
        MoveNFTsViewModel.NFT.mock(),
        MoveNFTsViewModel.NFT.mock(),
        MoveNFTsViewModel.NFT.mock()
    ]
    @Published var isMock = true
    @Published var showHint = false
    
    let limitCount = 4

    init() {
        fetchNFTs()
    }
    
    func moveAction() {
        guard let collection = selectedCollection?.collection else {
            return
        }
        Task {
            do {
                let address = collection.address // "0x8920ffd3d8768daa"
                let name = collection.contractName // "ExampleNFT"
                let ids: [UInt64] = nfts.compactMap { nft in
                    if !nft.isSelected {
                        return nil
                    }
                    let nftId = nft.model.id
                    guard let resultId = UInt64(nftId) else {
                        return nil
                    }
                    return resultId
                }
                let fromEvm = EVMAccountManager.shared.selectedAccount != nil
                let tid = try await FlowNetwork.bridgeNFTToEVM(contractAddress: address, contractName: name, ids: ids, fromEvm: fromEvm)
                let holder = TransactionManager.TransactionHolder(id: tid, type: .moveAsset)
                TransactionManager.shared.newTransaction(holder: holder)
                let result = try await tid.onceSealed()
                if result.isFailed {
                    return
                }
                fetchNFTs()
                log.info("[Move] NFT TIX: \(tid)")
            }
            catch {
                log.error(" Move NFTs =====")
                log.error(error)
            }
        }
    }
    
    func selectCollectionAction() {
        let vm = SelectCollectionViewModel(selectedItem: selectedCollection, list: collectionList) { item in
            self.selectedCollection = item
        }
        Router.route(to: RouteMap.NFT.selectCollection(vm))
    }
    
    func closeAction() {
        Router.dismiss()
    }
    
    func toggleSelection(of nft: MoveNFTsViewModel.NFT) {
        showHint = selectedCount >= limitCount
        if let index = nfts.firstIndex(where: { $0.id == nft.id }) {
            if !nfts[index].isSelected && selectedCount >= limitCount {
                
            }else {
                nfts[index].isSelected.toggle()
            }
        }
    }
    
    var selectedCount: Int {
        nfts.filter { $0.isSelected }.count
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
                    self.collectionList = response.data ?? []
                    if self.selectedCollection == nil {
                        self.selectedCollection = self.collectionList.first
                    }
                    if self.selectedCollection != nil {
                        self.fetchNFTs()
                    }
                }
            }
            catch {
                log.error("[MoveAsset] fetch Collection failed:\(error)")
            }
        }
    }
    
    func fetchNFTs(_ offset: Int = 0) {
        guard let collection = selectedCollection else {
            fetchCollection()
            return
        }
        Task {
            do {
                let address = WalletManager.shared.selectedAccountAddress
                let request = NFTCollectionDetailListRequest(address: address, collectionIdentifier: collection.collection.id, offset: offset, limit: 30)
                let response: NFTListResponse = try await Network.request(FRWAPI.NFT.collectionDetailList(request))
                DispatchQueue.main.async {
                    if let list = response.nfts {
                        self.nfts = list.map { MoveNFTsViewModel.NFT(isSelected: false, model: $0) }
                    }
                    else {
                        self.nfts = []
                    }
                    self.isMock = false
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.nfts = []
                    self.isMock = false
                }
                log.error("[MoveAsset] fetch NFTs failed:\(error)")
            }
        }
    }
}

extension MoveNFTsViewModel {
    private func emojiAccount(isFirst: Bool) -> WalletAccount.Emoji {
        let address = accountAddress(isFirst: isFirst)
        return WalletManager.shared.walletAccount.readInfo(at: address)
    }
    
    func accountIcon(isFirst: Bool) -> some View {
        return emojiAccount(isFirst: isFirst).icon(size: 20)
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
        return !(isFirst && (isFirst == !isSelectedEVM))
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
        var model: NFTResponse
        
        var imageUrl: String {
            return model.thumbnail ?? ""
        }
        
        static func mock() -> MoveNFTsViewModel.NFT {
            MoveNFTsViewModel.NFT(isSelected: false, model: NFTResponse.mock())
        }
    }
}
