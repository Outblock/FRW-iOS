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
    
    var callback:(CollectionMask)->()?
    
    init(selectedItem: CollectionMask?, list: [CollectionMask]?, callback:@escaping (CollectionMask)->()?) {
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
                let response: Network.Response<[NFTCollection]> = try await Network.requestWithRawModel(FRWAPI.NFT.userCollection(address,0,100))
                DispatchQueue.main.async {
                    self.list = response.data ?? []
                    if self.selectedItem == nil {
                        self.selectedItem = self.list.first
                    }
                }
                
            }
            catch {
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
        self.selectedItem = item
        confirmAction()
    }
    
    func confirmAction() {
        if let item = self.selectedItem {
            self.callback(item)
        }
        closeAction()
    }
    
    func isSelected(_ item: CollectionMask) -> Bool {
        return item.maskContractName == selectedItem?.maskContractName && item.maskName == selectedItem?.maskName
    }
}