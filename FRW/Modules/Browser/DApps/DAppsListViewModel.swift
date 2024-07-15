//
//  DAppsListViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 29/6/2023.
//

import SwiftUI
import Combine

class DAppsListViewModel: ObservableObject {
    @Published var dAppsList: [DAppModel] = []
    @Published var categoryList: [String] = []
    @Published var selectedCategory: String = "all"
    
    var filterdList: [DAppModel] {
        if selectedCategory == "all" {
            return dAppsList
        }
        
        return dAppsList.filter { $0.category.lowercased() == selectedCategory }
    }
    
    init() {
        fetchAction()
    }
    
    func fetchAction() {
        Task {
            do {
                
                let config: RemoteConfigManager.ENVConfig = try FirebaseConfig.ENVConfig.fetch(decoder: JSONDecoder())
                
                guard config.prod.features.appList ?? false else {
                    return
                }
                
                let list: [DAppModel] = try FirebaseConfig.dapp.fetch(decoder: JSONDecoder())
                let filterdList = list.filter{ $0.networkURL != nil }
                
                let categories = filterdList.map { $0.category.lowercased() }.reduce(into: [String]()) { result, category in
                    if !result.contains(where: { $0 == category }) {
                        result.append(category)
                    }
                }.sorted()
                
                DispatchQueue.main.async {
                    self.dAppsList = filterdList
                    self.selectedCategory = "all"
                    
                    var cList = ["all"]
                    cList.append(contentsOf: categories)
                    self.categoryList = cList
                }
            } catch {
                log.error("fetch data failed", context: error)
            }
        }
    }
    
    func changeCategory(_ category: String) {
        selectedCategory = category
    }
}
