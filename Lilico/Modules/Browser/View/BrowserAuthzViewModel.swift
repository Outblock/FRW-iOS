//
//  BrowserAuthzViewModel.swift
//  Flow Reference Wallet
//
//  Created by Selina on 6/9/2022.
//

import SwiftUI
import Highlightr

extension BrowserAuthzViewModel {
    typealias Callback = (Bool) -> ()
}

class BrowserAuthzViewModel: ObservableObject {
    @Published var title: String
    @Published var urlString: String
    @Published var logo: String?
    @Published var cadence: String
    @Published var cadenceFormatted: AttributedString?
    @Published var isScriptShowing: Bool = false
    
    @Published var template: FlowTransactionTemplate?
    
    private var callback: BrowserAuthzViewModel.Callback?
    
    init(title: String, url: String, logo: String?, cadence: String, callback: @escaping BrowserAuthnViewModel.Callback) {
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
    
    func formatCode() {
        guard let highlightr = Highlightr() else {
            return
        }
        highlightr.setTheme(to: "paraiso-dark")
            // You can omit the second parameter to use automatic language detection.
        guard let highlightedCode = highlightr.highlight(cadence, as: "swift") else {
            return
        }
        cadenceFormatted = AttributedString(highlightedCode)
    }
    
    func checkTemplate() {
        
        let network = LocalUserDefaults.shared.flowNetwork.rawValue.lowercased()
        guard let dataString = cadence.data(using: .utf8)?.base64EncodedString() else {
            return
        }
        let request = FlixAuditRequest(cadenceBase64: dataString, network: network)
    
        Task {
            do {
                let response: FlowTransactionTemplate = try await Network.requestWithRawModel(FlixAuditEndpoint.template(request), decoder: JSONDecoder())
                await MainActor.run {
                    self.template = response
                }
            } catch {
                print(error)
            }
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
