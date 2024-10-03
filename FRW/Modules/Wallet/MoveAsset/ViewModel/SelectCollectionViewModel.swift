//
//  SelectCollectionViewModel.swift
//  FRW
//
//  Created by cat on 2024/5/20.
//

import Foundation
import SwiftUI

class SelectCollectionViewModel: ObservableObject {
    @Published var list: [CollectionMask] = []
    @Published var selectedItem: CollectionMask?
    @Published var isMock = false

    var callback: (CollectionMask) -> Void?

    init(selectedItem: CollectionMask?, list: [CollectionMask]?, callback: @escaping (CollectionMask) -> Void?) {
        self.selectedItem = selectedItem
        self.callback = callback

        if let list = list {
            self.list = list
        }

        if self.list.isEmpty {
            self.list = [NFTCollection.mock(), NFTCollection.mock(), NFTCollection.mock()]
            fetchList()
        }
    }

    func fetchList() {
        Task {
            do {
                let address = WalletManager.shared.selectedAccountAddress
                let offset = FRWAPI.Offset(start: 0, length: 100)
                let from: FRWAPI.From = EVMAccountManager.shared.selectedAccount != nil ? .evm : .main
                let response: Network.Response<[NFTCollection]> = try await Network.requestWithRawModel(FRWAPI.NFT.userCollection(address, offset, from))
                DispatchQueue.main.async {
                    self.list = response.data ?? []
                    if self.selectedItem == nil {
                        self.selectedItem = self.list.first
                    }
                }
            } catch {
                log.error("[SelectCollection] fetch failed:\(error)")
            }
        }
    }

    func logo() -> Image {
        let isSelectedEVM = EVMAccountManager.shared.selectedAccount != nil
        return isSelectedEVM ? Image("icon_qr_evm") : Image("Flow")
    }
}

extension SelectCollectionViewModel {
    func closeAction() {
        Router.dismiss()
    }

    func select(item: CollectionMask) {
        selectedItem = item
        confirmAction()
    }

    func confirmAction() {
        if let item = selectedItem {
            callback(item)
        }
        closeAction()
    }

    func isSelected(_ item: CollectionMask) -> Bool {
        return item.maskContractName == selectedItem?.maskContractName && item.maskName == selectedItem?.maskName
    }
}
