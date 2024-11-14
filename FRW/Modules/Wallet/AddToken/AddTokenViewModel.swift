//
//  AddTokenViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 27/6/2022.
//

import Combine
import Flow
import SwiftUI

extension AddTokenViewModel {
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
        case addToken
        case selectToken
    }
}

// MARK: - AddTokenViewModel

class AddTokenViewModel: ObservableObject {
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

                var sections = [AddTokenViewModel.Section]()
                for (index, title) in sectionTitleArr.enumerated() {
                    let section = AddTokenViewModel.Section()
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

extension AddTokenViewModel {
    var searchResults: [AddTokenViewModel.Section] {
        if searchText.isEmpty {
            return sections
        }

        var searchSections: [AddTokenViewModel.Section] = []

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
                let newSection = AddTokenViewModel.Section()
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

extension AddTokenViewModel {
    func selectTokenAction(_ token: TokenModel) {
        if token.id == selectedToken?.id {
            Router.dismiss()
            return
        }

        selectCallback?(token)
        Router.dismiss()
    }

    func willActiveTokenAction(_ token: TokenModel) {
        if token.isActivated {
            return
        }

        guard let symbol = token.symbol else {
            return
        }

        if TransactionManager.shared.isTokenEnabling(symbol: symbol) {
            // TODO: show processing bottom view
            return
        }

        pendingActiveToken = token
        withAnimation(.easeInOut(duration: 0.2)) {
            confirmSheetIsPresented = true
        }
    }

    func confirmActiveTokenAction(_ token: TokenModel) {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            return
        }

        let failedBlock = {
            DispatchQueue.main.async {
                self.isRequesting = false
                HUD.dismissLoading()
                HUD.error(title: "add_token_failed".localized)
            }
        }

        isRequesting = true

        Task {
            do {
                let transactionId = try await FlowNetwork.enableToken(
                    at: Flow.Address(hex: address),
                    token: token
                )

                guard let data = try? JSONEncoder().encode(token) else {
                    failedBlock()
                    return
                }

                DispatchQueue.main.async {
                    self.isRequesting = false
                    self.confirmSheetIsPresented = false
                    let holder = TransactionManager.TransactionHolder(
                        id: transactionId,
                        type: .addToken,
                        data: data
                    )
                    TransactionManager.shared.newTransaction(holder: holder)
                }
            } catch {
                debugPrint("AddTokenViewModel -> confirmActiveTokenAction error: \(error)")
                isRequesting = false
                failedBlock()
            }
        }
    }
}
