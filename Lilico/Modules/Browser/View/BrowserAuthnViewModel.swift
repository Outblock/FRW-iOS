//
//  BrowserAuthnViewModel.swift
//  Flow Reference Wallet
//
//  Created by Selina on 6/9/2022.
//

import SwiftUI
import Flow

extension BrowserAuthnViewModel {
    typealias Callback = (Bool) -> ()
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
         callback: @escaping BrowserAuthnViewModel.Callback) {
        self.title = title
        self.urlString = url
        self.logo = logo
        self.network = network
        self.walletAddress = walletAddress
        self.callback = callback
    }
    
    func didChooseAction(_ result: Bool) {
        callback?(result)
        callback = nil
        Router.dismiss()
    }
    
    deinit {
        callback?(false)
        WalletConnectManager.shared.reloadPendingRequests()
    }
}
