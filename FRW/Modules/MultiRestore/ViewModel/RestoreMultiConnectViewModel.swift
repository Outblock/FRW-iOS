//
//  RestoreMultiConnectViewModel.swift
//  FRW
//
//  Created by cat on 2024/1/7.
//

import Foundation

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
    
    func checkValidUser() -> [[MultiBackupManager.StoreItem]] {
        let count = storeItems.count
        var result: [String: [MultiBackupManager.StoreItem]] = [:]
        for index in 0..<count {
            let preList = storeItems[index]
            for nextIndex in (index + 1)..<count {
                let nextList = storeItems[nextIndex]
                preList.forEach { preItem in
                    nextList.forEach { nextItem in
                        if preItem.userId == nextItem.userId {
                            if var exitList = result[preItem.userId] {
                                exitList.append(preItem)
                                exitList.append(nextItem)
                                result[preItem.userId] = exitList
                            }
                            else {
                                result[preItem.userId] = [preItem, nextItem]
                            }
                        }
                    }
                }
            }
        }
        let res = result.values.map { $0 }
        return res
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
