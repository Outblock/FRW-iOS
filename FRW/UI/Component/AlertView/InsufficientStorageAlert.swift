//
//  InsufficientStorageAlert.swift
//  FRW
//
//  Created by Antonio Bello on 11/26/24.
//

import SwiftUI

extension AlertViewController {
    static func showInsufficientStorageError(minimumBalance: Double) {
        AlertViewController.presentOnRoot(
            title: .init("insufficient_storage::error::title".localized),
            customContentView: AnyView(
                VStack(alignment: .center, spacing: 8) {
                    Text(.init("insufficient_storage::error::content::first".localized))
                    Text(.init("insufficient_storage::error::content::second".localized(minimumBalance)))
                        .foregroundColor(Color.LL.Button.Warning.background)
                    Text(.init("insufficient_storage::error::content::third".localized))
                        .padding(.top, 8)
                }
                    .padding(.vertical, 8)
            ),
            buttons: [
                AlertView.ButtonItem(type: .secondaryAction, title: "Deposit::message".localized, action: {
                    Router.route(to: RouteMap.Wallet.receive)
                }),
                AlertView.ButtonItem(type: .primaryAction, title: "buy_flow".localized, action: {
                    Router.route(to: RouteMap.Wallet.buyCrypto)
                })
            ],
            useDefaultCancelButton: false,
            showCloseButton: true,
            buttonsLayout: .horizontal,
            textAlignment: .center
        )
    }
}
