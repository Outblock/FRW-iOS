//
//  RestoreMultiConnectViewModel.swift
//  FRW
//
//  Created by cat on 2024/1/7.
//

import Foundation
import Flow

class RestoreMultiConnectViewModel: ObservableObject {
    let items: [MultiBackupType]
    @Published var enable: Bool = true
    @Published var currentIndex: Int = 0 {
        didSet {
            if currentIndex < items.count {
                currentType = items[currentIndex]
            }
        }
    }

    @Published var process: BackupProcess = .idle
    @Published var isEnd: Bool = false
    var currentType: MultiBackupType = .google
    
    var storeItems: [[MultiBackupManager.StoreItem]] = []
    var phraseItem: MultiBackupManager.StoreItem?
    
    init(items: [MultiBackupType]) {
        self.items = items
        currentIndex = 0
        if !self.items.isEmpty {
            currentType = self.items[0]
        }
    }
}

// MARK: Action

extension RestoreMultiConnectViewModel {
    func onClickButton() {
        if isEnd {
            let list = checkValidUser()
            Router.route(to: RouteMap.RestoreLogin.multiAccount(list))
            return
        }
        if currentType == .phrase {
            Router.route(to: RouteMap.RestoreLogin.inputMnemonic({ str in
                self.createStoreItem(with: str)
            }))
            return 
        }
        enable = false
        Task {
            do {
                let list = try await MultiBackupManager.shared.getCloudDriveItems(from: currentType)
                
                DispatchQueue.main.async {
                    self.storeItems.append(list)
                    let nextIndex = self.currentIndex + 1
                    if self.items.count <= nextIndex {
                        self.currentIndex = nextIndex
                        self.isEnd = true
                    }
                    else {
                        self.currentIndex = nextIndex
                    }
                    self.enable = true
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.enable = true
                }
            }
        }
    }
    
    private func createStoreItem(with mnemonic: String) {
        guard let hdWallet = WalletManager.shared.createHDWallet(mnemonic: mnemonic), let mnemonicData = hdWallet.mnemonic.data(using: .utf8) else {
            HUD.error(title: "empty_wallet_key".localized)
            return
        }
        let key = LocalEnvManager.shared.backupAESKey
        do {
            let dataHexString = try MultiBackupManager.shared.encryptMnemonic(mnemonicData, password: key)
            let publicKey = hdWallet.getPublicKey()
            var item = MultiBackupManager.StoreItem(address: "", userId: "", userName: "", publicKey: publicKey, data: dataHexString, keyIndex: 0, signAlgo: Flow.SignatureAlgorithm.ECDSA_P256.index, hashAlgo: Flow.HashAlgorithm.SHA2_256.index, weight: 500, deviceInfo: IPManager.shared.toParams())
            self.phraseItem = item
            let nextIndex = self.currentIndex + 1
            if self.items.count <= nextIndex {
                self.currentIndex = nextIndex
                self.isEnd = true
            }
            else {
                self.currentIndex = nextIndex
            }
            self.enable = true
        }
        catch {
            
        }
        
        
       
    }
    
    func checkValidUser() -> [[MultiBackupManager.StoreItem]] {
        
        var items: [String: [MultiBackupManager.StoreItem]] = [:]
        storeItems.forEach { list in
            list.forEach { storeItem in
                if var exitList = items[storeItem.userId] {
                    exitList.append(storeItem)
                    items[storeItem.userId] = exitList
                }else {
                    items[storeItem.userId] = [storeItem]
                }
            }
        }
        var result = items.values.map { list in
            var res = list
            if let phraseItem = self.phraseItem {
                res.append(phraseItem)
            }
            return res
        }
        result = result.filter { $0.count > 1 }
        return result
        
//        let count = storeItems.count
//        var result: [String: [MultiBackupManager.StoreItem]] = [:]
//        for index in 0..<count {
//            let preList = storeItems[index]
//            for nextIndex in (index + 1)..<count {
//                let nextList = storeItems[nextIndex]
//                preList.forEach { preItem in
//                    nextList.forEach { nextItem in
//                        if preItem.userId == nextItem.userId {
//                            if var exitList = result[preItem.userId] {
//                                exitList.append(preItem)
//                                exitList.append(nextItem)
//                                result[preItem.userId] = exitList
//                            }
//                            else {
//                                result[preItem.userId] = [preItem, nextItem]
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        let res = result.values.map { $0 }
//        return res
    }
}

// MARK: UI

extension RestoreMultiConnectViewModel {
    var currentIcon: String {
        currentType.iconName()
    }
    
    var currentTitle: String {
        if isEnd {
            return "prepared_to_restore".localized
        }
        return "connect_to_x".localized(currentType.title)
    }
    
    var currentNote: String {
        currentType.noteDes
    }
    
    var currentButton: String {
        if isEnd {
            return "restore_wallet".localized
        }
        return "connect".localized + " " + currentType.title
    }
}
