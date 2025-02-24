//
//  TokenBalanceListViewModel.swift
//  FRW
//
//  Created by Hao Fu on 24/2/2025.
//

import Combine
import Flow
import SwiftUI

extension TokenBalanceListViewModel {
    class Section: ObservableObject, Identifiable, Indexable {
        @Published
        var sectionName: String = "#"
        @Published
        var tokenList: [TokenModel] = []

        var id: String {
            sectionName
        }

        var index: Index? {
            Index(sectionName, contentID: id)
        }
    }

    enum Mode {
        case selectToken
    }
}

// MARK: - AddTokenViewModel

class TokenBalanceListViewModel: ObservableObject {
    // MARK: Lifecycle

    init(
        selectedToken: TokenModel? = nil,
        disableTokens: [TokenModel] = [],
        selectCallback: ((TokenModel) -> Void)? = nil
    ) {
        self.selectedToken = selectedToken
        self.disableTokens = disableTokens
        self.selectCallback = selectCallback

        if selectCallback != nil {
            self.mode = .selectToken
        }

        WalletManager.shared.$activatedCoins.sink { _ in
            DispatchQueue.main.async {
                self.reloadData()
            }
        }.store(in: &cancelSets)
    }

    // MARK: Internal

    @Published
    var sections: [Section] = []
    @Published
    var searchText: String = ""

    @Published
    var confirmSheetIsPresented = false
    var pendingActiveToken: TokenModel?

    var mode: AddTokenViewModel.Mode = .addToken
    var selectedToken: TokenModel?
    var disableTokens: [TokenModel] = []
    var selectCallback: ((TokenModel) -> Void)?

    @Published
    var isRequesting: Bool = false

    // MARK: Private

    private var cancelSets = Set<AnyCancellable>()

    private func reloadData() {
        guard let supportedTokenList = WalletManager.shared.supportedCoins else {
            sections = []
            return
        }

        var seenNames = Set<String>()
        var uniqueList = [TokenModel]()

        for token in supportedTokenList {
            if !seenNames.contains(token.contractId) {
                uniqueList.append(token)
                seenNames.insert(token.contractId)
            }
        }

        regroup(uniqueList)
    }

    private func regroup(_ tokens: [TokenModel]) {
        BMChineseSort.share.compareTpye = .fullPinyin
        BMChineseSort
            .sortAndGroup(
                objectArray: tokens,
                key: "name"
            ) { success, _, sectionTitleArr, sortedObjArr in
                if !success {
                    assertionFailure("can not be here")
                    return
                }

                var sections = [TokenBalanceListViewModel.Section]()
                for (index, title) in sectionTitleArr.enumerated() {
                    let section = TokenBalanceListViewModel.Section()
                    section.sectionName = title
                    section.tokenList = sortedObjArr[index]
                    sections.append(section)
                }

                DispatchQueue.main.async {
                    self.sections = sections
                }
            }
    }
}

extension TokenBalanceListViewModel {
    var searchResults: [TokenBalanceListViewModel.Section] {
        if searchText.isEmpty {
            return sections
        }

        var searchSections: [TokenBalanceListViewModel.Section] = []

        for section in sections {
            var list = [TokenModel]()

            for token in section.tokenList {
                if token.name.localizedCaseInsensitiveContains(searchText) {
                    list.append(token)
                    continue
                }

                if token.contractName.localizedCaseInsensitiveContains(searchText) {
                    list.append(token)
                    continue
                }

                if let symbol = token.symbol, symbol.localizedCaseInsensitiveContains(searchText) {
                    list.append(token)
                    continue
                }
            }

            if !list.isEmpty {
                let newSection = TokenBalanceListViewModel.Section()
                newSection.sectionName = section.sectionName
                newSection.tokenList = list
                searchSections.append(newSection)
            }
        }

        return searchSections
    }

    func isDisabledToken(_ token: TokenModel) -> Bool {
        for disToken in disableTokens {
            if disToken.id == token.id {
                return true
            }
        }

        return false
    }

    func isActivatedToken(_ token: TokenModel) -> Bool {
        if mode == .selectToken {
            return token.id == selectedToken?.id
        } else {
            return token.isActivated
        }
    }
}

// MARK: - Action

extension TokenBalanceListViewModel {
    func selectTokenAction(_ token: TokenModel) {
        if token.id == selectedToken?.id {
            Router.dismiss()
            return
        }

        selectCallback?(token)
        Router.dismiss()
    }
}
