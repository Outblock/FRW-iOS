//
//  BrowserAuthnViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 6/9/2022.
//

import Flow
import SwiftUI

extension BrowserAuthnViewModel {
    typealias Callback = (Bool) -> Void
}

class BrowserAuthnViewModel: ObservableObject {
    @Published var title: String
    @Published var urlString: String
    @Published var walletAddress: String?
    @Published var logo: String?
    @Published var network: Flow.ChainID?
    private var callback: BrowserAuthnViewModel.Callback?

    init(title: String,
         url: String,
         logo: String?,
         walletAddress: String?,
         network: Flow.ChainID? = nil,
         callback: @escaping BrowserAuthnViewModel.Callback)
    {
        self.title = title
        urlString = url
        self.logo = logo
        self.network = network
        self.walletAddress = walletAddress
        self.callback = callback
    }

    func didChooseAction(_ result: Bool) {
        Router.dismiss { [weak self] in
            guard let self else { return }
            callback?(result)
            callback = nil
        }
        
    }

    deinit {
        callback?(false)
        WalletConnectManager.shared.reloadPendingRequests()
    }
}
