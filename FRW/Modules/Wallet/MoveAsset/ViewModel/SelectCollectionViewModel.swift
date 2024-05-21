//
//  SelectCollectionViewModel.swift
//  FRW
//
//  Created by cat on 2024/5/20.
//

import Foundation
import SwiftUI

class SelectCollectionViewModel: ObservableObject {
    
    @Published var list: [NFTCollection] = []
    @Published var selectedItem: NFTCollection?
    @Published var isMock = false
    
    var callback:(NFTCollection)->()?
    
    init(selectedItem: NFTCollection?, list: [NFTCollection]?, callback:@escaping (NFTCollection)->()?) {
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
    
    func select(item: NFTCollection) {
        self.selectedItem = item
        confirmAction()
    }
    
    func confirmAction() {
        if let item = self.selectedItem {
            self.callback(item)
        }
        closeAction()
    }
    
    func isSelected(_ item: NFTCollection) -> Bool {
        return item.collection.contractName == selectedItem?.collection.contractName && item.collection.name == selectedItem?.collection.name
    }
}
