//
//  InboxViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 19/9/2022.
//

import Combine
import SwiftUI
import SwiftUIPager

private let CacheKey = "InboxViewCache"

extension InboxViewModel {
    enum TabType: Int, CaseIterable {
        case token
        case nft
    }
}

class InboxViewModel: ObservableObject {
    @Published var tabType: InboxViewModel.TabType = .token
    @Published var page: Page = .first()
    @Published var tokenList: [InboxToken] = []
    @Published var nftList: [InboxNFT] = []
    @Published var isRequesting: Bool = false

    private var cancelable = Set<AnyCancellable>()

    init() {
        loadCache()
        fetchData()

        NotificationCenter.default.publisher(for: .transactionManagerDidChanged).sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.fetchData()
            }
        }.store(in: &cancelable)
    }
}

extension InboxViewModel {
    private func fetchData() {
        guard let domain = UserManager.shared.userInfo?.meowDomain else {
            return
        }

        if isRequesting {
            return
        }

        isRequesting = true

        Task {
            do {
                let response: InboxResponse = try await Network.requestWithRawModel(FRWAPI.Flowns.queryInbox(domain))
                DispatchQueue.main.async {
                    self.isRequesting = false
                    self.fetchSuccess(response)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isRequesting = false
                    HUD.error(title: "inbox_request_failed".localized)
                }
            }
        }
    }

    private func fetchSuccess(_ response: InboxResponse) {
        tokenList = response.tokenList
        nftList = response.nftList

        saveCache(response)
    }
}

extension InboxViewModel {
    private func saveCache(_ response: InboxResponse) {
        PageCache.cache.set(value: response, forKey: CacheKey)
    }

    private func loadCache() {
        Task {
            if let response = try? await PageCache.cache.get(forKey: CacheKey, type: InboxResponse.self) {
                DispatchQueue.main.async {
                    self.tokenList = response.tokenList
                    self.nftList = response.nftList
                }
            }
        }
    }
}

extension InboxViewModel {
    func changeTabTypeAction(type: InboxViewModel.TabType) {
        withAnimation(.easeInOut(duration: 0.2)) {
            tabType = type
            page.update(.new(index: type.rawValue))
        }
    }

    func claimTokenAction(_ model: InboxToken) {
        guard let coin = model.matchedCoin, let domainHost = UserManager.shared.userInfo?.meowDomainHost else {
            return
        }

        HUD.loading()

        Task {
            do {
                let txid = try await FlowNetwork.claimInboxToken(domain: domainHost,
                                                                 key: model.key,
                                                                 coin: coin,
                                                                 amount: Decimal(model.amount))
                let data = try JSONEncoder().encode(model)

                DispatchQueue.main.async {
                    HUD.dismissLoading()

                    let holder = TransactionManager.TransactionHolder(id: txid, type: .common, data: data)
                    TransactionManager.shared.newTransaction(holder: holder)
                }
            } catch {
                debugPrint("InboxViewModel -> claimTokenAction failed: \(error)")
                HUD.dismissLoading()
                HUD.error(title: "inbox_claim_failed".localized)
            }
        }
    }

    func claimNFTAction(_ model: InboxNFT) {
        guard let collection = model.localCollection, let domainHost = UserManager.shared.userInfo?.meowDomainHost else {
            return
        }

        HUD.loading()

        Task {
            do {
                let txid = try await FlowNetwork.claimInboxNFT(domain: domainHost, key: model.key, collection: collection, itemId: UInt64(model.tokenId) ?? 0)
                let data = try JSONEncoder().encode(model)

                DispatchQueue.main.async {
                    HUD.dismissLoading()

                    let holder = TransactionManager.TransactionHolder(id: txid, type: .common, data: data)
                    TransactionManager.shared.newTransaction(holder: holder)
                }
            } catch {
                HUD.dismissLoading()
                HUD.error(title: "inbox_claim_failed".localized)
            }
        }
    }

    func openNFTCollectionAction(_ model: InboxNFT) {
        guard let urlString = model.localCollection?.officialWebsite, let url = URL(string: urlString) else {
            return
        }

        Router.route(to: RouteMap.Explore.browser(url))
    }
}
