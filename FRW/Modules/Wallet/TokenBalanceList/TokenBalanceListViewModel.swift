//
//  TokenBalanceListViewModel.swift
//  FRW
//
//  Created by Hao Fu on 24/2/2025.
//

import Combine
import Flow
import SwiftUI

// MARK: - TokenBalanceListViewModel

class TokenBalanceListViewModel: ObservableObject {
    // MARK: Lifecycle

    init(
        address: FWAddress,
        selectCallback: ((TokenModel) -> Void)? = nil
    ) {
        self.selectCallback = selectCallback
        self.address = address

        Task {
            await fetchData()
        }
    }

    // MARK: Internal

    var tokenList: [TokenModel] = .mock(5)
    var selectedToken: TokenModel?
    var selectCallback: ((TokenModel) -> Void)?

    @Published
    var isRequesting: Bool = false

    // MARK: Private

    private var address: FWAddress
    private var cancelSets = Set<AnyCancellable>()

    private func fetchData() async {
        do {
            await MainActor.run {
                isRequesting = true
            }

            let tokens = try await TokenBalanceHandler.shared.getFTBalance(address: address)
            tokenList = tokens

            await MainActor.run {
                isRequesting = false
            }
        } catch {
            // TODO: Add error retry logic
            HUD.error(title: "Something__went__wrong__please__try__again::message".localized)
            await MainActor.run {
                isRequesting = false
            }
            log.error(error)
        }
    }
}

// MARK: - Action

extension TokenBalanceListViewModel {
    func selectTokenAction(_ token: TokenModel) {
        selectCallback?(token)
        Router.dismiss()
    }
}
