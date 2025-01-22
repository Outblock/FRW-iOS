//
//  BrowserAuthzViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 6/9/2022.
//

import Flow
import Highlightr
import SwiftUI

// MARK: - BrowserAuthzViewModel.Callback

extension BrowserAuthzViewModel {
    typealias Callback = (Bool) -> Void
}

// MARK: - BrowserAuthzViewModel

final class BrowserAuthzViewModel: ObservableObject {
    // MARK: Lifecycle

    init(
        title: String,
        url: String,
        logo: String?,
        cadence: String,
        arguments: [Flow.Argument]? = nil,
        toAddress: String? = nil,
        data: String? = nil,
        amount: String? = nil,
        callback: @escaping BrowserAuthnViewModel.Callback
    ) {
        self.title = title
        self.urlString = url
        self.logo = logo
        self.cadence = cadence
        self.arguments = arguments
        self.callback = callback
        self.callData = data

        checkForInsufficientStorage()
        fetchEVMDecodeData(to: toAddress, data: data)

        if let toAddress {
            let name = data == nil ? "address".localized : "Contact Address".localized
            let model = FormItem(value: .object([name: .string(toAddress)]))
            infoList.append(model)
        }
        if let amount {
            let model =
                FormItem(value: .object(["Amount::message".localized: .string(amount + " FLOW")]))
            infoList.append(model)
        }
    }

    deinit {
        callback?(false)
        WalletConnectManager.shared.reloadPendingRequests()
    }

    // MARK: Internal

    @Published
    var title: String
    @Published
    var urlString: String
    @Published
    var logo: String?
    @Published
    var cadence: String
    @Published
    var cadenceFormatted: AttributedString?
    @Published
    var arguments: [Flow.Argument]?
    @Published
    var argumentsFormatted: AttributedString?
    @Published
    var isScriptShowing: Bool = false

    @Published
    var template: FlowTransactionTemplate?

    @Published
    var infoList: [FormItem] = []
    @Published
    var decodedDataList: [[FormItem]] = []
    @Published
    var callData: String? = nil
    @Published
    var showEvmCard: Bool = false

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
        argumentsFormatted = AttributedString(
            arguments.map { $0.value.description }
                .joined(separator: "\n\n")
        )
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
                let response: FlowTransactionTemplate = try await Network.requestWithRawModel(
                    FlixAuditEndpoint.template(request),
                    decoder: JSONDecoder()
                )
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

    func fetchEVMDecodeData(to address: String?, data: String?) {
        guard !EVMAccountManager.shared.accounts.isEmpty else {
            return
        }
        showEvmCard = true
        guard let address = address, let data = data else {
            return
        }
        Task {
            do {
                let response: DecodeResponse = try await Network
                    .requestWithRawModel(FRWAPI.EVM.decodeData(
                        address,
                        data
                    ))
                var tmp: [[FormItem]] = []
                let isVerified = response.isVerified ?? false

                if let topValue = response.decodedData?.allPossibilities {
                    let topItem = FormItem(
                        value: .object(["Contact": .string(response.name ?? "")]),
                        isCheck: isVerified
                    )
                    switch topValue {
                    case let .object(dictionary):
                        let list = parseTopDic(item: dictionary, topItem: topItem)
                        tmp.append(list)
                    case let .array(array):
                        let list = parseTopArray(items: array, topItem: topItem)
                        tmp.append(contentsOf: list)
                    default:
                        break
                    }
                }
                let result = tmp
                await MainActor.run {
                    withAnimation {
                        self.decodedDataList = result
                    }
                }
            } catch {
                log.error("[Decode] \(error)")
            }
        }
    }

    // MARK: Private

    private var callback: BrowserAuthzViewModel.Callback?
    private var _insufficientStorageFailure: InsufficientStorageFailure?

    private func parseTopArray(items: [JSONValue], topItem: FormItem) -> [[FormItem]] {
        guard let firstItem = items.first else {
            return []
        }
        var tmp: [[FormItem]] = []
        switch firstItem {
        case let .object(dictionary):
            let list = parseTopDic(item: dictionary, topItem: topItem)
            tmp.append(list)
        default:
            break
        }
        return tmp
    }

    private func parseTopDic(item: [String: JSONValue], topItem: FormItem) -> [FormItem] {
        var tmp: [FormItem] = [topItem]
        let keys = item.keys.map { $0 }.sorted()
        for key in keys {
            if let value = item[key] {
                let model = FormItem(value: .object([key: value]))
                tmp.append(model)
            }
        }
        return tmp
    }
}

// MARK: InsufficientStorageToastViewModel

extension BrowserAuthzViewModel: InsufficientStorageToastViewModel {
    var variant: InsufficientStorageFailure? { _insufficientStorageFailure }

    private func checkForInsufficientStorage() {
        _insufficientStorageFailure = insufficientStorageCheckForTransfer(token: .none)
    }
}

extension BrowserAuthzViewModel {
    struct DecodeResponse: Codable {
        let name: String?
        let isVerified: Bool?
        let abi: [String]?
        let decodedData: DecodeData?
    }

    struct DecodeData: Codable {
        let allPossibilities: JSONValue?
    }
}
