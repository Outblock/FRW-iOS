//
//  BrowserSignMessageViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 7/9/2022.
//

import SwiftUI

extension BrowserSignMessageViewModel {
    typealias Callback = (Bool) -> ()
}

class BrowserSignMessageViewModel: ObservableObject {
    @Published var title: String
    @Published var urlString: String
    @Published var logo: String?
    @Published var cadence: String
    @Published var isScriptShowing: Bool = false
    
    var message: String {
        let data = Data(hex: cadence)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    private var callback: BrowserSignMessageViewModel.Callback?
    
    init(title: String, url: String, logo: String?, cadence: String, callback: @escaping BrowserSignMessageViewModel.Callback) {
        self.title = title
        self.urlString = url
        self.logo = logo
        self.cadence = cadence
        self.callback = callback
    }
    
    func didChooseAction(_ result: Bool) {
        callback?(result)
        callback = nil
        Router.dismiss()
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
