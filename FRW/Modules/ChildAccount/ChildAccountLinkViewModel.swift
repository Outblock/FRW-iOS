//
//  ChildAccountLinkViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 15/6/2023.
//

import Combine
import Flow
import SwiftUI

extension ChildAccountLinkViewModel {
    typealias Callback = (Bool) -> Void

    enum State {
        case idle
        case processing
        case success
        case fail

        // MARK: Internal

        var confirmBtnTitle: String {
            switch self {
            case .success:
                return "start".localized
            case .fail:
                return "try_it_again".localized
            default:
                return ""
            }
        }
    }
}

// MARK: - ChildAccountLinkViewModel

class ChildAccountLinkViewModel: ObservableObject {
    // MARK: Lifecycle

    init(
        fromTitle: String,
        url: String,
        logo: String,
        callback: ChildAccountLinkViewModel.Callback? = nil
    ) {
        self.fromTitle = fromTitle
        self.url = url
        self.logo = logo
        self.callback = callback

        NotificationCenter.default.publisher(for: .transactionStatusDidChanged)
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink { [weak self] noti in
                self?.onTransactionStatusChanged(noti)
            }.store(in: &cancelSets)
    }

    deinit {
        callback?(false)
    }

    // MARK: Internal

    @Published
    var state: ChildAccountLinkViewModel.State = .idle

    @Published
    var fromTitle: String
    @Published
    var url: String
    @Published
    var logo: String

    var title: String {
        switch state {
        case .idle:
            return "link_account".localized
        case .processing:
            return "account_linking".localized
        case .success:
            return "successful".localized
        case .fail:
            return "link_failure".localized
        }
    }

    func linkAction() {
        callback?(true)
        callback = nil
    }

    func onTxID(_ txId: Flow.ID) {
        self.txId = txId
        changeState(.processing)
    }

    func onConfirmBtnAction() {
        Router.dismiss()
    }

    // MARK: Private

    private var callback: ChildAccountLinkViewModel.Callback?

    private var txId: Flow.ID?
    private var cancelSets = Set<AnyCancellable>()

    private func changeState(_ newState: ChildAccountLinkViewModel.State) {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.state = newState
        }
    }

    @objc
    private func onTransactionStatusChanged(_ noti: Notification) {
        guard let obj = noti.object as? TransactionManager.TransactionHolder,
              obj.transactionId.hex == self.txId?.hex else {
            return
        }

        switch obj.internalStatus {
        case .success:
            changeState(.success)
            ChildAccountManager.shared.refresh()
        case .failed:
            changeState(.fail)
        default:
            break
        }
    }
}
