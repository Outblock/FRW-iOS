//
//  BrowserViewController+JS.swift
//  Lilico
//
//  Created by Selina on 2/9/2022.
//

import UIKit
import WebKit

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
      uid: 'Lilico',
      endpoint: 'chrome-extension://hpclkefagolihohboafpheddmmgdffjm/popup.html',
      method: 'EXT/RPC',
      id: 'hpclkefagolihohboafpheddmmgdffjm',
      identity: {
        address: '0x33f75ff0b830dcec',
      },
      provider: {
        address: '0x33f75ff0b830dcec',
        name: 'Lilico',
        icon: 'https://lilico.app/logo.png',
        description: 'Lilico is bringing an out of the world experience to your crypto assets on Flow',
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
    case flowTransaction = "FLOW::TX"
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
                debugPrint("\(error)")
            }
        }
    }
    
    func postPreAuthzResponse() {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            return
        }
        
        postMessage(FCLScripts.generatePreAuthzResponse(address: address))
    }
    
    func postAuthnViewReadyResponse(response: FCLAuthnResponse) async throws {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            return
        }
        
        var accountProofSign = ""
        
        if let nonce = response.body.nonce,
           !nonce.isEmpty,
           let proofSign = response.encodeAccountProof(address: address),
           let sign = WalletManager.shared.signSync(signableData: proofSign) {
            accountProofSign = sign.hexValue
        }
        
        let message = try await FCLScripts.generateAuthnResponse(accountProofSign: accountProofSign, nonce: response.body.nonce ?? "", address: address)
        
        DispatchQueue.syncOnMain {
            postMessage(message)
        }
    }
    
    func postAuthzPayloadSignResponse(response: FCLAuthzResponse) async throws {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            return
        }
        
        let data = Data(hex: response.body.message)
        let signData = try await WalletManager.shared.sign(signableData: data)
        
        // TODO: Make it dynamic when there is mutiple keys
         let keyId = 0
//        let keyId = try await FlowNetwork.getLastBlockAccountKeyId(address: address)
        
        let message = FCLScripts.generateAuthzResponse(address: address, signature: signData.hexValue, keyId: keyId)
        DispatchQueue.syncOnMain {
            postMessage(message)
        }
    }
    
    func postAuthzEnvelopeSignResponse(sign: FCLVoucher.Signature) {
        let message = FCLScripts.generateAuthzResponse(address: sign.address.hex.addHexPrefix(), signature: sign.sig, keyId: sign.keyId)
        postMessage(message)
    }
    
    func postReadyResponse() {
        postMessage("{type: '\(JSMessageType.ready.rawValue)'}")
    }
    
    func postSignMessageResponse(_ response: FCLSignMessageResponse) {
        guard let address = WalletManager.shared.getPrimaryWalletAddress(),
              let message = response.body?.message,
              let js = FCLScripts.generateSignMessageResponse(message: message, address: address) else {
            debugPrint("BrowserViewController -> postSignMessageResponse: generate js failed")
            return
        }
        
        postMessage(js)
    }
    
    func postMessage(_ message: String) {
        let js = "window && window.postMessage(JSON.parse(JSON.stringify(\(message) || {})), '*')"
        
        webView.evaluateJavaScript(js) { result, error in
            if let error = error {
                debugPrint("BrowserViewController -> postMessage error: \(error)")
            }
        }
    }
}
