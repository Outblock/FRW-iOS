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
    
    /*
    var provider: Web3HttpProvider!
    var web3: Web3!
    var hdWallet: HDWallet!
    let address = Flow.Address(hex: "0xd962e1938ab387c8")
    var ethAddress: EthereumAddress!
    
    func setup() {
        Task {
            self.provider = try! await Web3HttpProvider(url: URL(string: "https://previewnet.evm.nodes.onflow.org")!, network: Networks.Custom(networkID: 646))
            self.web3 = Web3(provider: provider)
            self.hdWallet = HDWallet(mnemonic: "kiwi erosion weather slam harvest move crumble zero juice steel start hotel", passphrase: "")!
            self.ethAddress = EthereumAddress("0x0000000000000000000000029a9d22fe53a8fc9f")!
        }
    }
     */
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
        let msg = "this is a message"
        let address = Flow.Address(hex: "0xd962e1938ab387c8")

        guard let textData = msg.data(using: .utf8) else {
            return
        }
        
//        let hashedData = Hash.sha256(data: textData)
        let hashedData = Utilities.hashPersonalMessage(textData)!
        let joinData = Flow.DomainTag.user.normalize + hashedData
        let signableData = Hash.sha256(data: joinData)
        let sig = signWithHD(data: signableData)
        
        let proof = COAOwnershipProof(keyIninces: [0], address: address.data, capabilityPath: "evm", signatures: [sig])
        let encoded = RLP.encode(proof.rlpList)!
        
        /*
        print("message data ===> \(textData.hexString)")
        print("hashed message ===> \(hashedData.hexString)")
        print("signableData message ===> \(signableData.hexString)")
        print("sig ===> \(sig.hexString)")
        print("encoded ===> \(encoded.hexString)")
        
        Task {
            self.provider = try! await Web3HttpProvider(url: URL(string: "https://previewnet.evm.nodes.onflow.org")!, network: Networks.Custom(networkID: 646))
            self.web3 = Web3(provider: provider)
            self.hdWallet = HDWallet(mnemonic: "kiwi erosion weather slam harvest move crumble zero juice steel start hotel", passphrase: "")!
            self.ethAddress = EthereumAddress("0x0000000000000000000000029a9d22fe53a8fc9f")!
            let contract = web3.contract(coaABI, at: ethAddress)!
            let read = contract.createReadOperation("isValidSignature", parameters: [hashedData, encoded])!
            let response = try await read.callContractMethod()
            guard let data = response["0"] as? Data else {
                return
            }
            print(response)
            print(data.hexValue) // 1626ba7e
        }
        */
        
        // show alert
        let title = webVC?.webView.title ?? "unknown"
        let url = webVC?.webView.url
        let vm = BrowserSignMessageViewModel(title: title,
                                             url: url?.host ?? "unknown",
                                             logo: url?.absoluteString.toFavIcon()?.absoluteString,
                                             cadence: "")
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
    
    private func signWithHD(data: Data) -> Data {
        let hdWallet = HDWallet(mnemonic: "kiwi erosion weather slam harvest move crumble zero juice steel start hotel", passphrase: "")!
        let pk = hdWallet.getKeyByCurve(curve: .secp256k1, derivationPath: WalletManager.flowPath)
        print("pk  ===> \(pk.data.hexValue)")
        return pk.sign(digest: data, curve: .secp256k1)!.dropLast()
    }
}
