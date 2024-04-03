//
//  TrustJSMessageHandler.swift
//  FRW
//
//  Created by cat on 2024/3/4.
//

import BigInt
import Flow
import Foundation
import TrustWeb3Provider
import WalletCore
import Web3Core
import web3swift
import WebKit

class TrustJSMessageHandler: NSObject {
    weak var webVC: BrowserViewController?
}

// MARK: - helper

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
    
    private func extractMessage(json: [String: Any]) -> Data? {
        guard
            let params = json["object"] as? [String: Any],
            let string = params["data"] as? String,
            let data = Data(hexString: string)
        else {
            return nil
        }
        return data
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
            print("[Trust] signRawTransaction")
        case .signTransaction:
            print("[Trust] signTransaction")
        case .signMessage:
            print("[Trust] signMessage")
        case .signTypedMessage:
            print("[Trust] signTypedMessage")
        case .signPersonalMessage:
            guard let data = extractMessage(json: json) else {
                print("[Trust] data is missing")
                return
            }
            handleSignPersonal(network: network, id: id, data: data, addPrefix: true)
        case .sendTransaction:
            print("[Trust] sendTransaction")
        case .ecRecover:
            print("[Trust] ecRecover")

        case .watchAsset:
            print("[Trust] watchAsset")
        case .addEthereumChain:
            print("[Trust] addEthereumChain")
        case .switchEthereumChain:
            print("[Trust] switchEthereumChain")
        case .switchChain:
            print("[Trust] switchChain")
        }
    }
}

extension TrustJSMessageHandler {
    private func handleRequestAccounts(network: ProviderNetwork, id: Int64) {
        let address = webVC?.trustProvider.config.ethereum.address ?? ""

        let title = webVC?.webView.title ?? "unknown"
        let chainID = LocalUserDefaults.shared.flowNetwork.toFlowType()
        let url = webVC?.webView.url
        let vm = BrowserAuthnViewModel(title: title,
                                       url: url?.host ?? "unknown",
                                       logo: url?.absoluteString.toFavIcon()?.absoluteString,
                                       walletAddress: address,
                                       network: chainID)
        { [weak self] result in
            guard let self = self else {
                return
            }
            
            if result {
                switch network {
                case .ethereum:
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
    
    private func handleSignPersonal(network: ProviderNetwork, id: Int64, data: Data, addPrefix: Bool) {
        
        guard let addrStr = WalletManager.shared.getPrimaryWalletAddress() else {
            HUD.error(title: "invalid_address".localized)
            return
        }
        
        let address = Flow.Address(hex: addrStr)

        let hashedData = Utilities.hashPersonalMessage(data)!
        let joinData = Flow.DomainTag.user.normalize + hashedData
        let signableData = Hash.sha256(data: joinData) //TODO: #future by user type In the future
        guard let sig = signWithHD(data: signableData) else {
            HUD.error(title: "sign failed")
            return
        }
        
        let proof = COAOwnershipProof(keyIninces: [0], address: address.data, capabilityPath: "evm", signatures: [sig])
        let encoded = RLP.encode(proof.rlpList)!
        
        
        // show alert
        let title = webVC?.webView.title ?? "unknown"
        let url = webVC?.webView.url
        let vm = BrowserSignMessageViewModel(title: title,
                                             url: url?.absoluteString ?? "unknown",
                                             logo: url?.absoluteString.toFavIcon()?.absoluteString,
                                             cadence: data.hexString)
        { [weak self] result in
            guard let self = self else {
                return
            }
            
            if result {
                webVC?.webView.tw.send(network: .ethereum, result: encoded.hexString.addHexPrefix(), to: id)
            } else {
                webVC?.webView.tw.send(network: .ethereum, error: "Canceled", to: id)
            }
            
//            self.finishService()
        }
        
        Router.route(to: RouteMap.Explore.signMessage(vm))
    }
    
    
    
    private func signWithHD(data: Data) -> Data? {
        return WalletManager.shared.signSync(signableData: data)
    }
}
