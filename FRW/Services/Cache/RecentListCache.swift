//
//  RecentListCache.swift
//  Flow Wallet
//
//  Created by Selina on 15/7/2022.
//

import Combine
import Haneke
import SwiftUI

class RecentListCache: ObservableObject {
    static let cache = RecentListCache()
    private let recentListKey = "recent_list_cache"

    @Published var list: [Contact] = []

    private var cancelSet = Set<AnyCancellable>()

    init() {
        UserManager.shared.$activatedUID
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink { activatedUID in
                if activatedUID == nil {
                    self.clear()
                }
            }.store(in: &cancelSet)

        loadFromCache()
    }

    private func loadFromCache() {
        Shared.dataCache.fetch(key: recentListKey).onSuccess { data in
            do {
                let contacts = try JSONDecoder().decode([Contact].self, from: data)
                self.list = contacts
            } catch {
                self.list = []
            }
        }.onFailure { _ in
            self.list = []
        }
    }

    private func saveToCache() {
        do {
            let data = try JSONEncoder().encode(list)
            Shared.dataCache.set(value: data, key: recentListKey)
        } catch {
            log.error("save to cache failed", context: error)
        }
    }

    private func clear() {
        list.removeAll()
        saveToCache()
    }

    func append(contact: Contact) {
        var existIndex = -1
        var existContact: Contact?
        for (index, tempContact) in list.enumerated() {
            if tempContact.uniqueId == contact.uniqueId {
                existIndex = index
                existContact = tempContact
                break
            }
        }

        if let existContact = existContact {
            list.remove(at: existIndex)
            list.insert(existContact, at: 0)
        } else {
            list.insert(contact, at: 0)
        }

        saveToCache()
    }
}
