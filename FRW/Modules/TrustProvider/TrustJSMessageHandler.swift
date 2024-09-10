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
import CryptoKit
import Combine
import Web3Wallet



class TrustJSMessageHandler: NSObject {
    weak var webVC: BrowserViewController?
 
    var supportChainID: [Int: Flow.ChainID] = [
        LocalUserDefaults.FlowNetworkType.mainnet.networkID: .mainnet,
        LocalUserDefaults.FlowNetworkType.testnet.networkID: .testnet,
        LocalUserDefaults.FlowNetworkType.previewnet.networkID: .previewnet,
    ]
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
    
    private func extractObject(json: [String: Any]) -> [String: Any]? {
        guard let obj = json["object"] as? [String: Any] else {
            return nil
        }
        return obj
    }
    
    private func extractEthereumChainId(json: [String: Any]) -> Int? {
        guard
            let params = json["object"] as? [String: Any],
            let string = params["chainId"] as? String,
            let chainId = Int(String(string.dropFirst(2)), radix: 16),
            chainId > 0
        else {
            return nil
        }
        return chainId
    }
}

extension TrustJSMessageHandler: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let json = message.json
        guard let method = extractMethod(json: json),
              let id = json["id"] as? Int64,
              let network = extractNetwork(json: json)
        else {
            log.error("[Trust] json:\(json)")
            return
        }

        switch method {
        case .requestAccounts:
            log.info("[Trust] requestAccounts")
            handleRequestAccounts(network: network, id: id)
        case .signRawTransaction:
            log.info("[Trust] signRawTransaction")
        case .signTransaction:
            log.info("[Trust] signTransaction")
            guard let obj = extractObject(json: json)
            else {
                log.info("[Trust] data is missing")
                return
            }
            handleSendTransaction(network: network, id: id, info: obj)
        case .signMessage:
            log.info("[Trust] signMessage")
            
        case .signTypedMessage:
            log.info("[Trust] signTypedMessage")
        case .signPersonalMessage:
            guard let data = extractMessage(json: json) else {
                log.info("[Trust] data is missing")
                return
            }
            handleSignPersonal(network: network, id: id, data: data, addPrefix: true)
        case .sendTransaction:
            log.info("[Trust] sendTransaction")
            
        case .ecRecover:
            log.info("[Trust] ecRecover")

        case .watchAsset:
            print("[Trust] watchAsset")
        case .addEthereumChain:
            log.info("[Trust] addEthereumChain")
        case .switchEthereumChain:
            log.info("[Trust] switchEthereumChain")
            switch network {
            case .ethereum:
                guard
                    let chainId = extractEthereumChainId(json: json)
                else {
                    print("chain id is invalid")
                    return
                }
                handleSwitchEthereumChain(id: id, chainId: chainId)
            case .solana, .aptos, .cosmos:
                fatalError()
            }
        case .switchChain:
            log.info("[Trust] switchChain")
        }
    }
}

extension TrustJSMessageHandler {
    private func handleRequestAccounts(network: ProviderNetwork, id: Int64) {
        
        
        
        let callback = { [weak self] in
            guard let self = self else {
                return
            }
            let address = webVC?.trustProvider?.config.ethereum.address ?? ""

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
        
        MoveAssetsAction.shared.startBrowserWithMoveAssets(appName: webVC?.webView.title, callback: callback)
        
    }
    
    private func handleSignPersonal(network: ProviderNetwork, id: Int64, data: Data, addPrefix: Bool) {
        
        var title = webVC?.webView.title ?? "unknown"
        if title.isEmpty {
            title = "unknown"
        }
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
                guard let addrStr = WalletManager.shared.getPrimaryWalletAddress() else {
                    HUD.error(title: "invalid_address".localized)
                    return
                }
                
                let address = Flow.Address(hex: addrStr)
                guard let hashedData = Utilities.hashPersonalMessage(data) else { return  }
                let joinData = Flow.DomainTag.user.normalize + hashedData
                guard let sig = signWithMessage(data: joinData) else {
                    HUD.error(title: "sign failed")
                    return
                }
                let keyIndex = BigUInt(WalletManager.shared.keyIndex)
                let proof = COAOwnershipProof(keyIninces: [keyIndex], address: address.data, capabilityPath: "evm", signatures: [sig])
                guard let encoded = RLP.encode(proof.rlpList) else {
                    return
                }
                webVC?.webView.tw.send(network: .ethereum, result: encoded.hexString.addHexPrefix(), to: id)
            } else {
                webVC?.webView.tw.send(network: .ethereum, error: "Canceled", to: id)
            }

        }
        
        Router.route(to: RouteMap.Explore.signMessage(vm))
    }
    
    private func handleSendTransaction(network: ProviderNetwork, id: Int64, info: [String: Any])  {
        
        var title = webVC?.webView.title ?? "unknown"
        if title.isEmpty {
            title = "unknown"
        }
        let url = webVC?.webView.url
        
        let originCadence = CadenceManager.shared.current.evm?.callContract?.toFunc() ?? ""
        
        let vm = BrowserAuthzViewModel(title: title,
                                             url: url?.absoluteString ?? "unknown",
                                             logo: url?.absoluteString.toFavIcon()?.absoluteString,
                                             cadence: originCadence)
        { [weak self] result in
            
            guard let self = self else {
                self?.webVC?.webView.tw.send(network: .ethereum, error: "Canceled", to: id)
                return
            }
            
            if result {
               
                Task {
                    do {
                        
                        guard let data = info.jsonData else {
                            self.cancel(id: id)
                            return
                        }
                        let receiveModel = try JSONDecoder().decode(EVMTransactionReceive.self, from: data)
                        guard let toAddr = receiveModel.toAddress else {
                            self.cancel(id: id)
                            return
                        }
                        let tix = try await FlowNetwork.sendTransaction(amount: receiveModel.amount, data: receiveModel.dataValue, toAddress: toAddr, gas: receiveModel.gasValue)
                        let result = try await tix.onceSealed()
                        if result.isFailed {
                            HUD.error(title: "transaction failed")
                            self.cancel(id: id)
                            return
                        }
                        let model = try await FlowNetwork.fetchEVMTransactionResult(txid: tix.hex)
                        DispatchQueue.main.async {
                            self.webVC?.webView.tw.send(network: .ethereum, result: model.hash ?? "", to: id)
                        }
                    }
                    catch {
                        log.error("\(error)")
                        self.cancel(id: id)
                    }
                }
                
            } else {
                self.webVC?.webView.tw.send(network: .ethereum, error: "Canceled", to: id)
            }
        }
        
        Router.route(to: RouteMap.Explore.authz(vm))
    }
    
    private func handleSwitchEthereumChain(id: Int64, chainId: Int) {
        guard let targetID = supportChainID[chainId] else {
            log.error("Unknown chain id: \(chainId)")
            HUD.error(title: "Unsupported ChainId: \(chainId)")
            webVC?.webView.tw.send(network: .ethereum, error: "Unknown chain id", to: id)
            return
        }

        let currentChainId = LocalUserDefaults.shared.flowNetwork.toFlowType()

        if targetID == currentChainId {
            log.info("No need to switch, already on chain \(chainId)")
            webVC?.webView.tw.sendNull(network: .ethereum, id: id)
        } else {
            guard let fromId = currentChainId.networkType, let toId = targetID.networkType else {
                log.error("Unknown chain id: \(chainId)")
                HUD.error(title: "Unsupported ChainId: \(chainId)")
                webVC?.webView.tw.send(network: .ethereum, error: "Unknown chain id", to: id)
                return
            }
            let callback: SwitchNetworkClosure = { [weak self] curId in
                if curId.toFlowType() == targetID {
                    log.info("Switch to \(chainId)")
                    self?.webVC?.webView.tw.sendNull(network: .ethereum, id: id)
                } else {
                    log.error("Unknown chain id: \(chainId)")
                    self?.webVC?.webView.tw.send(network: .ethereum, error: "Unknown chain id", to: id)
                }
            }
            Router.route(to: RouteMap.Explore.switchNetwork(fromId, toId, callback))
        }
    }
    
    
    
    private func signWithMessage(data: Data) -> Data? {
        return WalletManager.shared.signSync(signableData: data)
    }
    
    private func cancel(id: Int64) {
        DispatchQueue.main.async {
            self.webVC?.webView.tw.send(network: .ethereum, error: "Canceled", to: id)
        }
    }
}
