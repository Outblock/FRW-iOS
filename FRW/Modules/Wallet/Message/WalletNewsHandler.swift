//
//  WalletNewsHandler.swift
//  FRW
//
//  Created by cat on 2024/8/26.
//

import Foundation
import SwiftUI

private extension Array where Element == RemoteConfigManager.News {
    func appended(_ element: RemoteConfigManager.News) -> Self {
        var list = self
        list.append(element)
        return list
    }
    
    func appended(contentsOf news: [RemoteConfigManager.News]) -> Self {
        var list = self
        list.append(contentsOf: news)
        return list
    }
    
    func removeExpiryNew() -> Self {
        let currentData = Date()
        return filter { $0.expiryTime > currentData }
    }
    
    func removeMarkedNews(removeIds: [String]) -> Self {
        return filter { !removeIds.contains($0.id) }
    }
    
    func handleCondition(force: Bool = false) -> Self {
        return filter { model in
            guard let conditionList = model.conditions, !conditionList.isEmpty, force == false else {
                return true
            }
            return !conditionList.map { $0.type.boolValue() }.contains(false)
        }
    }
    
    func orderNews() -> Self {
        return sorted(by: >)
    }
    
    func addRemoteNews(_ news: [RemoteConfigManager.News]) -> Self {
        var list = self
        
        for news in news {
            if list.contains(where: { $0.id == news.id }) {
                continue
            }
            
            list = list
                .appended(news)
        }
        
        return list.orderNews()
    }
}

// MARK: - WalletNewsHandler

class WalletNewsHandler: ObservableObject {
    // MARK: Lifecycle

    private init() {
        self.removeIds = LocalUserDefaults.shared.removedNewsIds
        NotificationCenter.default.addObserver(self, selector: #selector(self.onAccountDataUpdate), name: .accountDataDidUpdate, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Internal

    static let shared = WalletNewsHandler()

    // TODO: Change it to Set
    @MainActor @Published var list: [RemoteConfigManager.News] = []
    
    var removeIds: [String] = [] {
        didSet {
            LocalUserDefaults.shared.removedNewsIds = removeIds
        }
    }

    /// Call only once when receive Firebase Config
    @MainActor
    func addRemoteNews(_ news: [RemoteConfigManager.News]) {
        var list: [RemoteConfigManager.News] = []
        
        accessQueue.sync {
            list = list
                .appended(contentsOf: news)
                .removeExpiryNew()
                .removeMarkedNews(removeIds: self.removeIds)
                .handleCondition()
                .orderNews()
            log.debug("[NEWS] count:\(list.count)")
        }
        
        self.list = list
    }

    @MainActor
    func removeNews(_ news: RemoteConfigManager.News) {
        var list = self.list
        
        accessQueue.sync {
            if let index = list.firstIndex(where: { $0.id == news.id }), list[safe: index] != nil {
                list.remove(at: index)
            }
        }
        
        self.list = list
    }

    func refreshWalletConnectNews(_ news: [RemoteConfigManager.News]) {
        DispatchQueue.main.async {
            var list = self.list
            
            self.accessQueue.sync { [weak self] in
                guard let self else { return }
                let tmpList = list
                
                for (index, new) in tmpList.enumerated() {
                    if new.flag == .walletconnect, list[safe: index] != nil {
                        list.remove(at: index)
                    }
                }
                
                list = list.addRemoteNews(news)
            }
            
            self.list = list
        }
    }

    /// Call only once when view appear
    @MainActor
    func checkFirstNews() {
        let list = self.list
        accessQueue.sync(flags: .barrier) { [weak self] in
            guard let self else { return }
            if let item = list.first {
                markItemIfNeed(item.id, displatyType: [.once])
            }
        }
        self.list = list
    }

    // MARK: Private
    
    private let accessQueue = DispatchQueue(
        label: "SynchronizedArrayAccess",
        attributes: .concurrent
    )

    @objc
    private func onAccountDataUpdate() {
        DispatchQueue.main.async {
            var list = self.list
            
            self.accessQueue.sync(flags: .barrier) {
                list = list
                    .handleCondition(force: true)
                    .orderNews()
            }
            
            self.list = list
        }
    }

    @discardableResult @MainActor
    private func markItemIfNeed(_ itemId: String, displatyType: [RemoteConfigManager.NewDisplayType] = [.once]) -> Bool {
        let item = list.first { $0.id == itemId }
        guard let type = item?.displayType, displatyType.contains(type) else {
            return false
        }
        accessQueue.sync(flags: .barrier) { [weak self] in
            guard let self else { return }
            removeIds.append(itemId)
        }
        return true
    }
}

// MARK: User Action

extension WalletNewsHandler {
    @MainActor
    func onShowItem(_ itemId: String) {
        markItemIfNeed(itemId, displatyType: [.once])
    }

    @MainActor
    func onCloseItem(_ itemId: String) {
        markItemIfNeed(itemId)
        withAnimation {
            list.removeAll { $0.id == itemId }
        }
    }

    @MainActor
    func onClickItem(_ itemId: String) {
        guard let item = list.first(where: { $0.id == itemId }) else { return }

        let shouldRemove = markItemIfNeed(itemId, displatyType: [.click, .once])

        if let urlStr = item.url, !urlStr.isEmpty, let url = URL(string: urlStr) {
            if urlStr.contains("apple.com") {
                UIApplication.shared.open(url)
            } else {
                Router.route(to: RouteMap.Explore.browser(url))
            }
        }

        if item.flag == .walletconnect,
           let request = WalletConnectManager.shared.pendingRequests
           .first(where: { $0.topic == item.id }) {
            WalletConnectManager.shared.handleRequest(request)
        }

        if shouldRemove {
            withAnimation {
                list.removeAll { $0.id == itemId }
            }
        }
    }

    @MainActor
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

    @MainActor
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

    @MainActor
    func onScroll(index: Int) {
        guard index < list.count else { return }

        let item = list[index]
        if item.displayType == .once {
            removeIds.append(item.id)
        }
    }
}
