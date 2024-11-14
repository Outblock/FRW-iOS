//
//  BrowserAuthzViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 6/9/2022.
//

import Flow
import Highlightr
import SwiftUI

extension BrowserAuthzViewModel {
    typealias Callback = (Bool) -> Void
}

class BrowserAuthzViewModel: ObservableObject {
    @Published var title: String
    @Published var urlString: String
    @Published var logo: String?
    @Published var cadence: String
    @Published var cadenceFormatted: AttributedString?
    @Published var arguments: [Flow.Argument]?
    @Published var argumentsFormatted: AttributedString?
    @Published var isScriptShowing: Bool = false

    @Published var template: FlowTransactionTemplate?

    private var callback: BrowserAuthzViewModel.Callback?
    private var _insufficientStorageFailure: InsufficientStorageFailure?
    
    init(title: String, url: String, logo: String?, cadence: String, arguments: [Flow.Argument]? = nil, callback: @escaping BrowserAuthnViewModel.Callback) {
        self.title = title
        urlString = url
        self.logo = logo
        self.cadence = cadence
        self.arguments = arguments
        self.callback = callback
        checkForInsufficientStorage()
    }

    func didChooseAction(_ result: Bool) {
        Router.dismiss { [weak self] in
            guard let self else { return }
            self.callback?(result)
            self.callback = nil
        }
    }

    func formatArguments() {
        guard let arguments else {
            return
        }
        argumentsFormatted = AttributedString(arguments.map { $0.value.description }.joined(separator: "\n\n"))
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

// MARK: - InsufficientStorageToastViewModel

extension BrowserAuthzViewModel: InsufficientStorageToastViewModel {
    var variant: InsufficientStorageFailure? { _insufficientStorageFailure }
    
    private func checkForInsufficientStorage() {
        self._insufficientStorageFailure = insufficientStorageCheck()
    }
}
