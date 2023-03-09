//
//  ScanHandler.swift
//  Lilico
//
//  Created by Selina on 8/8/2022.
//

import UIKit
import SwiftUI

class ScanHandler {
    
    static func handler() -> SPQRCodeCallback {
        return { data, vc in
            switch data {
            case .walletConnect(let string):
                vc.stopRunning()
                vc.presentingViewController?.dismiss(animated: true, completion: {
                    DispatchQueue.main.async {
                        WalletConnectManager.shared.connect(link: string)
                    }
                })
            case .flowWallet(let address):
                vc.stopRunning()
                vc.presentingViewController?.dismiss(animated: true, completion: {
                    
                    let symbol = LocalUserDefaults.shared.recentToken ?? "flow"
                    guard let token = WalletManager.shared.getToken(bySymbol: symbol) else {
                        return
                    }
                    let contract = Contact(address: address, avatar: nil, contactName: "-", contactType: .none, domain: nil, id: -1, username: nil)
                    Router.route(to: RouteMap.Wallet.sendAmount(contract, token, isPush: false))
                })
            default:
                break
            }
        }
    }
    
    static func clickHandler() -> SPQRCodeCallback {
        return { data, vc in
            switch data {
            case .walletConnect(let string):
                vc.stopRunning()
                vc.presentingViewController?.dismiss(animated: true, completion: {
                    DispatchQueue.main.async {
                        WalletConnectManager.shared.connect(link: string)
                    }
                })
            case .flowWallet(let address):
                vc.stopRunning()
                vc.presentingViewController?.dismiss(animated: true, completion: {
                    
                    let symbol = LocalUserDefaults.shared.recentToken ?? "flow"
                    guard let token = WalletManager.shared.getToken(bySymbol: symbol) else {
                        return
                    }
                    let contract = Contact(address: address, avatar: nil, contactName: "-", contactType: .none, domain: nil, id: -1, username: nil)
                    Router.route(to: RouteMap.Wallet.sendAmount(contract, token, isPush: false))
                })
            case let .text(text):
                UIPasteboard.general.string = text
                HUD.success(title: "copied".localized)
            case let .ethWallet(address):
                UIPasteboard.general.string = address
                HUD.success(title: "copied".localized)
            case let .url(url):
                vc.stopRunning()
                vc.presentingViewController?.dismiss(animated: true, completion: {
                    Router.route(to: RouteMap.Explore.browser(url))
                })
            }
        }
    }
    
    static func scan() {
        Router.route(to: RouteMap.Wallet.scan(ScanHandler.handler(), click: ScanHandler.clickHandler()))
    }
}
