//
//  BrowserSignMessageViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 7/9/2022.
//

import SwiftUI

extension BrowserSignMessageViewModel {
    typealias Callback = (Bool) -> Void
}

class BrowserSignMessageViewModel: ObservableObject {
    @Published var title: String
    @Published var urlString: String
    @Published var logo: String?
    @Published var cadence: String
    @Published var isScriptShowing: Bool = false
    var useRawMessage: Bool = false

    var message: String {
        if useRawMessage {
            return cadence
        }
        let data = Data(hex: cadence)
        return String(data: data, encoding: .utf8) ?? ""
    }

    private var callback: BrowserSignMessageViewModel.Callback?

    init(title: String, url: String, logo: String?, cadence: String, useRawMessage: Bool = false, callback: @escaping BrowserSignMessageViewModel.Callback) {
        self.title = title
        urlString = url
        self.logo = logo
        self.cadence = cadence
        self.callback = callback
        self.useRawMessage = useRawMessage
    }

    func didChooseAction(_ result: Bool) {
        Router.dismiss { [weak self] in
            guard let self else { return }
            self.callback?(result)
            self.callback = nil
        }
    }

    func changeScriptViewShowingAction(_ show: Bool) {
        withAnimation {
            self.isScriptShowing = show
        }
    }

    deinit {
        callback?(false)
        WalletConnectManager.shared.reloadPendingRequests()
    }
}
