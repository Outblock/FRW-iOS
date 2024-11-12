//
//  PageCache.swift
//  Flow Wallet
//
//  Created by Selina on 3/8/2022.
//

import Combine
import Haneke
import SwiftUI

// MARK: - PageCache

class PageCache {
    // MARK: Lifecycle

    init() {
        UserManager.shared.$activatedUID
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink { activatedUID in
                if activatedUID == nil {
                    self.clear()
                }
            }.store(in: &cancelSet)

        NotificationCenter.default.publisher(for: .didFinishAccountLogin)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.clear()
            }.store(in: &cancelSet)
    }

    // MARK: Internal

    static let cache = PageCache()

    // MARK: Private

    private var cacheObj = Cache<Data>(name: "PageCache")
    private var cancelSet = Set<AnyCancellable>()

    private func clear() {
        cacheObj.removeAll()
        createCache()
    }

    private func createCache() {
        cacheObj = Cache<Data>(name: "PageCache")
    }
}

extension PageCache {
    func set<T: Encodable>(value: T, forKey key: String) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(value)
            cacheObj.set(value: data, key: key)
        } catch {
            debugPrint("PageCache -> set failed: \(error)")
        }
    }

    func get<T: Decodable>(forKey key: String, type: T.Type) async throws -> T {
        try await withCheckedThrowingContinuation { config in
            cacheObj.fetch(key: key).onSuccess { data in
                do {
                    let result = try JSONDecoder().decode(type, from: data)
                    config.resume(returning: result)
                } catch {
                    config.resume(throwing: error)
                }
            }.onFailure { error in
                config.resume(throwing: error ?? LLError.unknown)
            }
        }
    }
}
