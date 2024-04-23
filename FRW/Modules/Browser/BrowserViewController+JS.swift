//
//  BrowserViewController+JS.swift
//  Flow Wallet
//
//  Created by Selina on 2/9/2022.
//

import UIKit
import WebKit
import TrustWeb3Provider

private let jsListenWindowFCLMessage = """
    window.addEventListener('message', function (event) {
      window.webkit.messageHandlers.message.postMessage(JSON.stringify(event.data))
    })
"""

private let jsListenFlowWalletTransaction = """
    window.addEventListener('FLOW::TX', function (event) {
      window.webkit.messageHandlers.transaction.postMessage(JSON.stringify({type: 'FLOW::TX', ...event.detail}))
    })
"""

private func generateFCLExtensionInject() -> String {
    let address = "0x33f75ff0b830dcec"
    
    let js = """
    const service = {
      f_type: 'Service',
      f_vsn: '1.0.0',
      type: 'authn',
      uid: 'Flow Wallet',
      endpoint: 'chrome-extension://hpclkefagolihohboafpheddmmgdffjm/popup.html',
      method: 'EXT/RPC',
      id: 'hpclkefagolihohboafpheddmmgdffjm',
      identity: {
        address: '0x33f75ff0b830dcec',
      },
      provider: {
        address: '0x33f75ff0b830dcec',
        name: 'Flow Wallet',
        icon: 'https://lilico.app/fcw-logo.png',
        description: 'Digital wallet created for everyone.',
      },
    }
    
     function injectExtService(service) {
      if (service.type === "authn" && service.endpoint != null) {
        if (!Array.isArray(window.fcl_extensions)) {
          window.fcl_extensions = []
        }
        window.fcl_extensions.push(service)
      } else {
        console.warn("Authn service is required")
      }
    }
    
    injectExtService(service);
    
    """
    
    return js
}

enum JSListenerType: String {
    case message
    case flowTransaction = "transaction"
}

extension BrowserViewController {
    var listenFCLMessageUserScript: WKUserScript {
        let us = WKUserScript(source: jsListenWindowFCLMessage, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        return us
    }
    
    var listenFlowWalletTransactionUserScript: WKUserScript {
        let us = WKUserScript(source: jsListenFlowWalletTransaction, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        return us
    }
    
    var extensionInjectUserScript: WKUserScript {
        let us = WKUserScript(source: generateFCLExtensionInject(), injectionTime: .atDocumentStart, forMainFrameOnly: true)
        return us
    }
    
    func generateWebViewConfiguration() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        let ucc = WKUserContentController()
        config.applicationNameForUserAgent = "Chrome/101.0.4951.67"
        ucc.add(self.jsHandler, name: JSListenerType.message.rawValue)
        ucc.add(self.jsHandler, name: JSListenerType.flowTransaction.rawValue)
        ucc.addUserScript(listenFCLMessageUserScript)
        ucc.addUserScript(listenFlowWalletTransactionUserScript)
        ucc.addUserScript(extensionInjectUserScript)
        // Trust Web3
        ucc.add(self.trustJSHandler, name: TrustWeb3Provider.scriptHandlerName)
        ucc.addUserScript(trustProvider.providerScript)
        ucc.addUserScript(trustProvider.injectScript)
        config.userContentController = ucc
        
        return config
    }
}

// MARK: - Post

extension BrowserViewController {
    func notifyFinish(callbackID: Int, value: String) {
        let script = "window.ethereum.sendResponse(\(callbackID), \"\(value)\")"
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                log.error("notify finish failed", context: error)
            }
        }
    }
    
    func postPreAuthzResponse() {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            log.error("primary address is nil")
            return
        }
        let keyIndex = WalletManager.shared.keyIndex
        log.debug("will post pre authz response")
        postMessage(FCLScripts.generatePreAuthzResponse(address: address,keyIndex: keyIndex))
        log.debug("did post pre authz response")
    }
    
    func postAuthnViewReadyResponse(response: FCLAuthnResponse) async throws {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            log.error("primary address is nil")
            return
        }
        
        var accountProofSign = ""
        
        if let nonce = response.body.nonce,
           !nonce.isEmpty,
           let proofSign = response.encodeAccountProof(address: address),
           let sign = WalletManager.shared.signSync(signableData: proofSign) {
            accountProofSign = sign.hexValue
        }
        let keyIndex = WalletManager.shared.keyIndex
        let message = try await FCLScripts.generateAuthnResponse(accountProofSign: accountProofSign, nonce: response.body.nonce ?? "", address: address, keyId: keyIndex)
        
        DispatchQueue.syncOnMain {
            log.debug("will post authn view ready response")
            postMessage(message)
            log.debug("did post authn view ready response")
        }
    }
    
    func postAuthzPayloadSignResponse(response: FCLAuthzResponse) async throws {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            log.error("primary address is nil")
            return
        }
        
        let data = Data(hex: response.body.message)
        let signData = try await WalletManager.shared.sign(signableData: data)
        
        let keyId = WalletManager.shared.keyIndex
//        let keyId = try await FlowNetwork.getLastBlockAccountKeyId(address: address)
        
        let message = FCLScripts.generateAuthzResponse(address: address, signature: signData.hexValue, keyId: keyId)
        DispatchQueue.syncOnMain {
            log.debug("will post authz payload sign response")
            postMessage(message)
            log.debug("did post authz payload sign response")
        }
    }
    
    func postAuthzEnvelopeSignResponse(sign: FCLVoucher.Signature) {
        let message = FCLScripts.generateAuthzResponse(address: sign.address.hex.addHexPrefix(), signature: sign.sig, keyId: sign.keyId)
        log.debug("will post authz envelope response")
        postMessage(message)
        log.debug("did post authz envelope response")
    }
    
    func postReadyResponse() {
        log.debug("will post ready response")
        postMessage("{type: '\(JSMessageType.ready.rawValue)'}")
        log.debug("did post ready response")
    }
    
    func postSignMessageResponse(_ response: FCLSignMessageResponse) {
        let keyIndex = WalletManager.shared.keyIndex
        guard let address = WalletManager.shared.getPrimaryWalletAddress(),
              let message = response.body?.message,
              let js = FCLScripts.generateSignMessageResponse(message: message, address: address,keyId: keyIndex) else {
            log.error("generate js failed")
            return
        }
        
        log.debug("will post sign message response")
        postMessage(js)
        log.debug("did post sign message response")
    }
    
    func postMessage(_ message: String) {
        let js = "window && window.postMessage(JSON.parse(JSON.stringify(\(message) || {})), '*')"
        
        webView.evaluateJavaScript(js) { result, error in
            if let error = error {
                log.error("post message error", context: error)
            }
        }
    }
}
