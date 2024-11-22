//
//  SelectProviderViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 2/12/2022.
//

import SwiftUI

class SelectProviderViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        self.lilicoProvider = StakingProviderCache.cache.providers.first { $0.isLilico }
        self.otherProviders = StakingProviderCache.cache.providers.filter { $0.isLilico == false }
    }

    // MARK: Internal

    @Published
    var lilicoProvider: StakingProvider?
    @Published
    var otherProviders: [StakingProvider] = []
}
