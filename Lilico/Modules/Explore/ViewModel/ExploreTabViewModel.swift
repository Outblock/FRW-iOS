//
//  ExploreTabViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 29/8/2022.
//

import Foundation
import Combine

extension ExploreTabScreen {
    struct ViewState {
        var isLoading: Bool = false
        var list: [DAppModel] = []
        var categoryList: [String] = []
        var selectedCategory: String = "all"
        
        var filterdList: [DAppModel] {
            if selectedCategory == "all" {
                return list
            }
            
            return list.filter { $0.category.lowercased() == selectedCategory }
        }
    }
    
    enum Action {
        case fetchList
    }
}

class ExploreTabViewModel: ViewModel {
    
    @Published
    var state: ExploreTabScreen.ViewState = .init()
    
    @Published var webBookmarkList: [WebBookmark] = []
    
    private var cancelSets = Set<AnyCancellable>()
    
    init() {
        reloadWebBookmark()
        
        NotificationCenter.default.publisher(for: .webBookmarkDidChanged).sink { [weak self] _ in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                self.reloadWebBookmark()
            }
        }.store(in: &cancelSets)
    }
    
    private func reloadWebBookmark() {
        var list = DBManager.shared.getAllWebBookmark()
        list = Array(list.prefix(10))
        webBookmarkList = list
    }
    
    func changeCategory(_ category: String) {
        state.selectedCategory = category
    }
    
    func trigger(_ input: ExploreTabScreen.Action) {
        switch input {
        case .fetchList:
            state.isLoading = true
            Task {
                do {
                    let config: RemoteConfigManager.Config = try await FirebaseConfig.config.fetch(decoder: JSONDecoder())
                    
                    guard config.features.appList ?? false else {
                        return
                    }
                    
                    let list: [DAppModel] = try await FirebaseConfig.dapp.fetch(decoder: JSONDecoder())
                    let filterdList = list.filter{ $0.networkURL != nil }
                    
                    let categories = filterdList.map { $0.category.lowercased() }.reduce(into: [String]()) { result, category in
                        if !result.contains(where: { $0 == category }) {
                            result.append(category)
                        }
                    }.sorted()
                    
                    await MainActor.run {
                        state.list = filterdList
                        
                        state.selectedCategory = "all"
                        
                        var cList = ["all"]
                        cList.append(contentsOf: categories)
                        state.categoryList = cList
                        
                        state.isLoading = false
                    }
                } catch {
                    state.isLoading = false
//                    HUD.error(title: "Fetch dApp")
                }
            }
        }
    }
    
}
