//
//  TrustJSMessageHandler.swift
//  FRW
//
//  Created by cat on 2024/3/4.
//

import Foundation
import TrustWeb3Provider
import WebKit
import Flow

class TrustJSMessageHandler: NSObject {
    weak var webVC: BrowserViewController?
}

extension TrustJSMessageHandler {
    private func extractMethod(json: [String: Any]) -> TrustAppMethod? {
        guard
            let name = json["name"] as? String
        else {
            return nil
        }
        return TrustAppMethod(rawValue: name)
    }

    private func extractNetwork(json: [String: Any]) -> ProviderNetwork? {
        guard
            let network = json["network"] as? String
        else {
            return nil
        }
        return ProviderNetwork(rawValue: network)
    }
}

extension TrustJSMessageHandler: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let json = message.json
        guard let method = extractMethod(json: json),
              let id = json["id"] as? Int64,
              let network = extractNetwork(json: json)
        else {
            return
        }

        switch method {
        case .requestAccounts:
            handleRequestAccounts(network: network, id: id)
        case .signRawTransaction:
            print("")
        case .signTransaction:
            print("")
        case .signMessage:
            print("")
        case .signTypedMessage:
            print("")
        case .signPersonalMessage:
            print("")
        case .sendTransaction:
            print("")
        case .ecRecover:
            print("")

        case .watchAsset:
            print("")
        case .addEthereumChain:
            print("")
        case .switchEthereumChain:
            print("")
        case .switchChain:
            print("")
        }
    }
}

extension TrustJSMessageHandler {
    private func handleRequestAccounts(network: ProviderNetwork, id: Int64) {
        
        let title = webVC?.webView.title ?? "unknown"
        let chainID = LocalUserDefaults.shared.flowNetwork.toFlowType()
        let url = webVC?.webView.url
        let vm = BrowserAuthnViewModel(title: title,
                                       url: url?.host ?? "unknown",
                                       logo: url?.absoluteString.toFavIcon()?.absoluteString,
                                       walletAddress: WalletManager.shared.getPrimaryWalletAddress(),
                                       network: chainID) { [weak self] result in
            guard let self = self else {
                return
            }
            
            if result {
                switch network {
                case .ethereum:
                    let address = self.webVC?.trustProvider.config.ethereum.address ?? "0x123456"
                    webVC?.webView.tw.set(network: network.rawValue, address: address)
                    webVC?.webView.tw.send(network: network, results: [address], to: id)
                default:
                    print("not support")
                }
            } else {
                webVC?.webView.tw.send(network: network, error: "Canceled", to: id)
                log.debug("handle authn cancelled")
            }
            
        }
        
        Router.route(to: RouteMap.Explore.authn(vm))
    }
}
