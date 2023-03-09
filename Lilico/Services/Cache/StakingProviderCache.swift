//
//  StakingProviderCache.swift
//  Lilico
//
//  Created by Selina on 30/11/2022.
//

import Foundation

class StakingProviderCache {
    static let cache = StakingProviderCache()
    
    private(set) var providers: [StakingProvider] = []
    
    private lazy var rootFolder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("staking")
    private lazy var providerCacheFile = rootFolder.appendingPathComponent("providers")
    
    private var isRefreshing: Bool = false
    
    init() {
        createFolderIfNeeded()
        loadFromCache()
        debugPrint("debug: providers.count = \(providers.count)")
        refresh()
    }
    
    private func createFolderIfNeeded() {
        do {
            if !FileManager.default.fileExists(atPath: rootFolder.relativePath) {
                try FileManager.default.createDirectory(at: rootFolder, withIntermediateDirectories: true)
            }
        } catch {
            debugPrint("StakingProviderCache -> createFolderIfNeeded error: \(error)")
        }
    }
    
    private func loadFromCache() {
        if !FileManager.default.fileExists(atPath: providerCacheFile.relativePath) {
            loadFromLocalFile()
            return
        }
        
        do {
            let data = try Data(contentsOf: providerCacheFile)
            let providers = try JSONDecoder().decode([StakingProvider].self, from: data)
            if providers.isEmpty {
                removeCache()
                loadFromLocalFile()
                return
            }
            
            self.providers = providers
        } catch {
            debugPrint("StakingProviderCache -> loadFromCache error: \(error)")
            removeCache()
            loadFromLocalFile()
        }
    }
    
    private func loadFromLocalFile() {
        do {
            guard let filePath = Bundle.main.path(forResource: "staking_provider", ofType: "json") else {
                debugPrint("StakingProviderCache -> loadFromLocalFile error: no local file")
                return
            }
            
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            let providers = try JSONDecoder().decode([StakingProvider].self, from: data)
            self.providers = providers
        } catch {
            debugPrint("StakingProviderCache -> loadFromLocalFile error: \(error)")
        }
    }
    
    private func saveDataToCache(_ data: Data) {
        do {
            try data.write(to: providerCacheFile)
        } catch {
            debugPrint("StakingProviderCache -> saveDataToCache: error: \(error)")
        }
    }
    
    private func removeCache() {
        if FileManager.default.fileExists(atPath: providerCacheFile.relativePath) {
            do {
                try FileManager.default.removeItem(at: providerCacheFile)
            } catch {
                debugPrint("StakingProviderCache -> removeCache error: \(error)")
            }
        }
    }
}

extension StakingProviderCache {
    private func refresh() {
        if isRefreshing {
            return
        }
        
        isRefreshing = true
        let url = URL(string: "https://raw.githubusercontent.com/Outblock/Assets/main/staking/staking.json")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isRefreshing = false
                
                guard let data = data else {
                    return
                }
                
                do {
                    let providers = try JSONDecoder().decode([StakingProvider].self, from: data)
                    if !providers.isEmpty {
                        self.providers = providers
                        self.saveDataToCache(data)
                        debugPrint("StakingProviderCache -> refreshed")
                    }
                } catch {
                    
                }
            }
        }
        
        task.resume()
    }
}
