//
//  WalletNewsHandler.swift
//  FRW
//
//  Created by cat on 2024/8/26.
//

import Foundation
import SwiftUI

class WalletNewsHandler: ObservableObject {
    
    static let shared = WalletNewsHandler()
    
    // TODO: Change it to Set
    @Published var list: [RemoteConfigManager.News] = []
    
    var removeIds: [String] = [] {
        didSet {
            LocalUserDefaults.shared.removedNewsIds = removeIds
        }
    }
    
    private init() {
        removeIds = LocalUserDefaults.shared.removedNewsIds
    }
    /// Call only once when receive Firebase Config
    func addRemoteNews(_ news: [RemoteConfigManager.News]) {
        list.removeAll()
        list.append(contentsOf: news)
        removeExpiryNew()
        removeMarkedNews()
        orderNews()
        log.debug("[NEWS] count:\(list.count)")
    }
    
    func addRemoteNews(_ news: RemoteConfigManager.News) {
        if list.contains(where: { $0.id == news.id }) {
            return
        }
        
        list.append(news)
        orderNews()
    }
    
    func removeNews(_ news: RemoteConfigManager.News) {
        if let index = list.firstIndex(where: { $0.id == news.id }) {
            list.remove(at: index)
            orderNews()
        }
    }
    
    func refreshWalletConnectNews(_ news: [RemoteConfigManager.News]) {
        for (index, new) in list.enumerated() {
            if new.flag == .walletconnect {
                list.remove(at: index)
            }
        }
        
        for item in news {
            addRemoteNews(item)
        }
    }
    
    private func removeExpiryNew() {
        let currentData = Date()
        list = list.filter { $0.expiryTime > currentData }
    }
    
    private func removeMarkedNews() {
        list = list.filter { !removeIds.contains($0.id) }
    }
    
    private func orderNews() {
        list.sort(by: >)
    }
    
    @discardableResult
    private func markItemIfNeed(_ itemId: String, displatyType: [RemoteConfigManager.NewDisplayType] = [.once]) -> Bool {
        let item = list.first { $0.id == itemId }
        guard let type = item?.displayType, displatyType.contains(type) else {
            return false
        }
        removeIds.append(itemId)
        return true
    }
    
    /// Call only once when view appear
    func checkFirstNews() {
        if let item = list.first {
            markItemIfNeed(item.id, displatyType: [.once])
        }
    }
}

//MARK: User Action
extension WalletNewsHandler {
    
    func onShowItem(_ itemId: String) {
        markItemIfNeed(itemId,displatyType: [.once])
    }
    
    func onCloseItem(_ itemId: String) {
        markItemIfNeed(itemId)
        withAnimation {
            list.removeAll { $0.id == itemId }
        }
    }
    
    func onClickItem(_ itemId: String) {
        guard let item = list.first(where: { $0.id == itemId }) else { return }
        
        let shouldRemove = markItemIfNeed(itemId, displatyType: [.click, .once])
        
        if let urlStr = item.url, !urlStr.isEmpty, let url = URL(string: urlStr) {
            Router.route(to: RouteMap.Explore.browser(url))
        }
        
        if item.flag == .walletconnect, let request = WalletConnectManager.shared.pendingRequests.first(where: { $0.topic == item.id }) {
            WalletConnectManager.shared.handleRequest(request)
        }
        
        if shouldRemove {
            withAnimation {
                list.removeAll { $0.id == itemId }
            }
        }
    }
    
    func nextItem(_ itemId: String) -> String? {
        guard let index = list.firstIndex(where: { $0.id == itemId }) else {
            return nil
        }
        guard index + 1 < list.count else {
            return nil
        }
        let item = list[index + 1]
        return item.id
    }
    
    func nextIndex(_ itemId: String) -> Int? {
        guard let index = list.firstIndex(where: { $0.id == itemId }) else {
            return nil
        }
        let nextIndex = index + 1
        guard nextIndex < list.count else {
            return nil
        }
        return nextIndex
    }
    
    func onScroll(index: Int) {
        guard index < list.count else { return }
    
        let item = list[index]
        if item.displayType == .once {
            removeIds.append(item.id)
        }
    }
}
