//
//  JSMessageHandler.swift
//  Lilico
//
//  Created by Selina on 5/9/2022.
//

import UIKit
import WebKit
import Flow

enum JSMessageType: String {
    case ready = "FCL:VIEW:READY"
    case response = "FCL:VIEW:READY:RESPONSE"
}

class JSMessageHandler: NSObject {
    private var processingMessage: String?
    private var processingServiceType: FCLServiceType?
    private var processingFCLResponse: FCLResponseProtocol?
    private var readyToSignEnvelope: Bool = false
    
    private(set) var processingAuthzTransaction: AuthzTransaction?
    
    weak var webVC: BrowserViewController?
}

extension JSMessageHandler: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch JSListenerType(rawValue: message.name) {
        case .message:
            guard let msgString = message.body as? String else {
                debugPrint("JSMessageHandler -> JSListenerType.message body invalid")
                return
            }
            
            handleMessage(msgString)
        case .flowTransaction:
            guard let msgString = message.body as? String else {
                debugPrint("JSMessageHandler -> JSListenerType.flowTransaction body invalid")
                return
            }
            
            handleTransaction(msgString)
        default:
            break
        }
    }
}

extension JSMessageHandler {
    private func handleTransaction(_ message: String) {
        do {
            guard let msgData = message.data(using: .utf8),
                  let jsonDict = try JSONSerialization.jsonObject(with: msgData, options: .mutableContainers) as? [String: AnyObject],
                  let tid = jsonDict["txId"] as? String else {
                debugPrint("JSMessageHandler -> handleTransaction: invalid message")
                return
            }
            
            guard let processingAuthzTransaction = processingAuthzTransaction, let data = try? JSONEncoder().encode(processingAuthzTransaction) else {
                debugPrint("JSMessageHandler -> handleTransaction: no processingAuthzTransaction")
                return
            }
            
            if TransactionManager.shared.isExist(tid: tid) {
                debugPrint("JSMessageHandler -> handleTransaction: tid is exist")
                return
            }
            
            debugPrint("JSMessageHandler -> handleTransaction")
            
            let id = Flow.ID(hex: tid)
            let holder = TransactionManager.TransactionHolder(id: id, type: .fclTransaction, data: data)
            TransactionManager.shared.newTransaction(holder: holder)
        } catch {
            debugPrint("JSMessageHandler -> handleTransaction: invalid message: \(error)")
        }
    }
}

extension JSMessageHandler {
    private func handleMessage(_ message: String) {
        if message.isEmpty || processingMessage == message {
            return
        }
        
        if WalletManager.shared.getPrimaryWalletAddress() == nil {
            HUD.error(title: "browser_not_login".localized)
            return
        }
        
        processingMessage = message
        debugPrint("JSMessageHandler -> handleMessage: \(message)")
        
        do {
            if let msgData = message.data(using: .utf8),
               let jsonDict = try JSONSerialization.jsonObject(with: msgData, options: .mutableContainers) as? [String: AnyObject] {
                if messageIsServce(jsonDict) {
                    handleService(message)
                } else if jsonDict["type"] as? String == JSMessageType.response.rawValue {
                    handleViewReadyResponse(message)
                } else {
                    debugPrint("JSMessageHandler -> handleMessage: unknown message")
                }
            } else {
                debugPrint("JSMessageHandler -> handleMessage: decode message failed")
            }
        } catch {
            debugPrint("JSMessageHandler -> handleMessage: invalid message: \(error)")
        }
    }
    
    private func messageIsServce(_ dict: [String: AnyObject]) -> Bool {
        guard dict["type"] == nil else {
            return false
        }
        
        guard let serviceDict = dict["service"] as? [String: AnyObject] else {
            return false
        }
        
        if serviceDict["type"] != nil || serviceDict["f_type"] as? String == "Service" {
            return true
        }
        
        return false
    }
    
    private func finishService() {
        self.processingServiceType = nil
        self.processingFCLResponse = nil
    }
}

// MARK: - Service

extension JSMessageHandler {
    private func handleService(_ message: String) {
        do {
            guard let data = message.data(using: .utf8) else {
                debugPrint("JSMessageHandler -> handleService: decode message failed")
                return
            }
            
            debugPrint("JSMessageHandler -> handleService")
            
            let serviceWrapper = try JSONDecoder().decode(JSFCLServiceModelWrapper.self, from: data)
            processingServiceType = serviceWrapper.service.type
            
            if processingServiceType == .preAuthz {
                webVC?.postPreAuthzResponse()
            } else {
                webVC?.postReadyResponse()
            }
        } catch {
            debugPrint("JSMessageHandler -> handleService: decode message failed: \(error)")
        }
    }
}

// MARK: - Response

extension JSMessageHandler {
    private func handleViewReadyResponse(_ message: String) {
        do {
            guard let data = message.data(using: .utf8) else {
                debugPrint("JSMessageHandler -> handleViewReadyResponse: decode message failed")
                return
            }
            
            let fcl = try JSONDecoder().decode(FCLSimpleResponse.self, from: data)
            
            if self.processingServiceType != fcl.serviceType {
                debugPrint("JSMessageHandler -> handleViewReadyResponse: service not same (old: \(String(describing: self.processingServiceType)), new: \(fcl.serviceType))")
                return
            }
            
            debugPrint("JSMessageHandler -> handleViewReadyResponse")
            
            switch fcl.serviceType {
            case .authn:
                handleAuthn(message)
            case .authz:
                handleAuthz(message)
            case .userSignature:
                handleUserSignature(message)
            default:
                debugPrint("JSMessageHandler -> handleViewReadyResponse: unsupport service type: \(fcl.serviceType)")
            }
        } catch {
            debugPrint("JSMessageHandler -> handleViewReadyResponse: decode message failed: \(error)")
        }
    }
    
    private func handleAuthn(_ message: String) {
        do {
            guard let data = message.data(using: .utf8) else {
                debugPrint("JSMessageHandler -> handleAuthn: decode message failed")
                return
            }
            
            let authnResponse = try JSONDecoder().decode(FCLAuthnResponse.self, from: data)
            
            if authnResponse.uniqueId() == processingFCLResponse?.uniqueId() {
                debugPrint("JSMessageHandler -> handleAuthn, is processing: \(authnResponse.uniqueId())")
                return
            }
            
            debugPrint("JSMessageHandler -> handleAuthn")
            processingFCLResponse = authnResponse
            
            let title = authnResponse.config?.app?.title ?? webVC?.webView.title ?? "unknown"
            let vm = BrowserAuthnViewModel(title: title,
                                           url: webVC?.webView.url?.host ?? "unknown",
                                           logo: authnResponse.config?.app?.icon,
                                           walletAddress: WalletManager.shared.getPrimaryWalletAddress()) { [weak self] result in
                guard let self = self else {
                    return
                }
                
                if result {
                    self.didConfirmAuthn(response: authnResponse)
                } else {
                    debugPrint("JSMessageHandler -> handleAuthn: cancelled")
                }
                
                self.finishService()
            }
            
            Router.route(to: RouteMap.Explore.authn(vm))
        } catch {
            debugPrint("JSMessageHandler -> handleAuthn: decode message failed: \(error)")
        }
    }
    
    private func didConfirmAuthn(response: FCLAuthnResponse) {
        Task {
            do {
                try await self.webVC?.postAuthnViewReadyResponse(response: response)
            } catch {
                debugPrint("JSMessageHandler -> didConfirmAuthn failed: \(error)")
                HUD.error(title: "browser_request_failed".localized)
            }
        }
    }
    
    private func handleAuthz(_ message: String) {
        do {
            guard let data = message.data(using: .utf8) else {
                debugPrint("JSMessageHandler -> handleAuthz: decode message failed")
                return
            }
            
            let authzResponse = try JSONDecoder().decode(FCLAuthzResponse.self, from: data)
            
            if authzResponse.uniqueId() == processingFCLResponse?.uniqueId() {
                debugPrint("JSMessageHandler -> handleAuthz, is processing: \(authzResponse.uniqueId())")
                return
            }
            
            debugPrint("JSMessageHandler -> handleAuthz")
            processingFCLResponse = authzResponse
            
            if authzResponse.body.f_type == "Signable" {
                debugPrint("JSMessageHandler -> handleAuthz, roles: \(authzResponse.body.roles.value)")
            }
            
            if authzResponse.isSignAuthz {
                debugPrint("JSMessageHandler -> signAuthz")
                signAuthz(authzResponse)
                return
            }
            
            if authzResponse.isSignPayload {
                debugPrint("JSMessageHandler -> signPayload")
                signPayload(authzResponse)
                return
            }
            
            if readyToSignEnvelope && authzResponse.isSignEnvelope {
                debugPrint("JSMessageHandler -> signEnvelope")
                signEnvelope(authzResponse)
                return
            }
            
            debugPrint("JSMessageHandler -> handleAuthz: unknown authz")
        } catch {
            debugPrint("JSMessageHandler -> handleAuthz: decode message failed: \(error)")
        }
    }
    
    private func handleUserSignature(_ message: String) {
        do {
            guard let data = message.data(using: .utf8) else {
                debugPrint("JSMessageHandler -> handleUserSignature: decode message failed")
                return
            }
            
            let response = try JSONDecoder().decode(FCLSignMessageResponse.self, from: data)
            
            if response.uniqueId() == processingFCLResponse?.uniqueId() {
                debugPrint("JSMessageHandler -> handleUserSignature, is processing: \(response.uniqueId())")
                return
            }
            
            processingFCLResponse = response
            debugPrint("JSMessageHandler -> handleUserSignature, uid: \(response.uniqueId())")
            
            let title = response.config?.app?.title ?? webVC?.webView.title ?? "unknown"
            let url = webVC?.webView.url?.host ?? "unknown"
            let vm = BrowserSignMessageViewModel(title: title, url: url, logo: response.config?.app?.icon, cadence: response.body?.message ?? "") { [weak self] result in
                guard let self = self else {
                    return
                }
                
                if result {
                    self.webVC?.postSignMessageResponse(response)
                }
                
                self.finishService()
            }
            
            Router.route(to: RouteMap.Explore.signMessage(vm))
        } catch {
            debugPrint("JSMessageHandler -> handleUserSignature: decode message failed: \(error)")
        }
    }
}

extension JSMessageHandler {
    private func signAuthz(_ authzResponse: FCLAuthzResponse) {
        let title = authzResponse.config?.app?.title ?? webVC?.webView.title ?? "unknown"
        let url = webVC?.webView.url?.host ?? "unknown"
        let vm = BrowserAuthzViewModel(title: title, url: url, logo: authzResponse.config?.app?.icon, cadence: authzResponse.body.cadence) { [weak self] result in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                if result {
                    self.processingAuthzTransaction = AuthzTransaction(url: self.webVC?.webView.url?.absoluteString, title: self.webVC?.webView.title, voucher: authzResponse.body.voucher)
                    self.didConfirmSignPayload(authzResponse)
                }
            }
            
            self.finishService()
        }
        
        Router.route(to: RouteMap.Explore.authz(vm))
    }
    
    private func signPayload(_ authzResponse: FCLAuthzResponse) {
        let title = authzResponse.config?.app?.title ?? webVC?.webView.title ?? "unknown"
        let url = webVC?.webView.url?.host ?? "unknown"
        let vm = BrowserAuthzViewModel(title: title, url: url, logo: authzResponse.config?.app?.icon, cadence: authzResponse.body.cadence) { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.readyToSignEnvelope = result
            if result {
                self.didConfirmSignPayload(authzResponse)
            } else {
                self.finishService()
            }
        }
        
        Router.route(to: RouteMap.Explore.authz(vm))
    }
    
    private func didConfirmSignPayload(_ response: FCLAuthzResponse) {
        Task {
            do {
                try await self.webVC?.postAuthzPayloadSignResponse(response:response)
            } catch {
                debugPrint("JSMessageHandler -> didConfirmSignPayload failed: \(error)")
                HUD.error(title: "browser_request_failed".localized)
            }
        }
    }
    
    private func signEnvelope(_ authzResponse: FCLAuthzResponse) {
        let url = self.webVC?.webView.url?.absoluteString
        let title = self.webVC?.webView.title
        
        Task {
            let request = SignPayerRequest(transaction: authzResponse.body.voucher.toFCLVoucher(), message: .init(envelopeMessage: authzResponse.body.message))
            let signature: SignPayerResponse = try await Network.requestWithRawModel(FirebaseAPI.signAsPayer(request))
            let sign = signature.envelopeSigs
            
            DispatchQueue.main.async {
                self.webVC?.postAuthzEnvelopeSignResponse(sign: sign)
                
                let authzTransaction = AuthzTransaction(url: url, title: title, voucher: authzResponse.body.voucher)
                self.processingAuthzTransaction = authzTransaction
                
                self.readyToSignEnvelope = false
                self.finishService()
            }
        }
    }
}
