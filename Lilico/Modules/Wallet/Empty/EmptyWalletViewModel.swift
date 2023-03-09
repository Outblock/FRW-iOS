//
//  EmptyWalletViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 25/12/21.
//

import Foundation

import SwiftUI
import SwiftUIX

struct EmptyWalletState {
    var dataSource: [CardDataSource]
}

enum EmptyWalletAction {
    case signUp
    case signIn
}

struct CardDataSource: Identifiable {
    var id = UUID().uuidString
    var title: String
    let bgGradient: [Color]
    let bgImage: Image
    let buttonText: String
    let icon: Image
    let iconColor: Color
    let action: EmptyWalletAction
}

class EmptyWalletViewModel: ViewModel {
    @Published private(set) var state: EmptyWalletState

    init() {
        let dataSource = [
            CardDataSource(title: "create_btn_desc".localized,
                           bgGradient: [.red, Color.LL.orange],
                           bgImage: Image(componentAsset: "Gradient-Circle")
                               .renderingMode(.original),
                           buttonText: "create_btn_text".localized,
                           icon: Image(systemName: "plus"),
                           iconColor: .purple,
                           action: .signUp),
            CardDataSource(title: "import_btn_desc".localized,
                           bgGradient: [Color(hex: "#659EAF"), Color(hex: "#88CBE1")],
                           bgImage: Image(componentAsset: "Gradient-Rect")
                               .renderingMode(.original),
                           buttonText: "import_btn_text".localized,
                           icon: Image(systemName: "arrow.forward.to.line"),
                           iconColor: .yellow,
                           action: .signIn),
        ]
        state = EmptyWalletState(dataSource: dataSource)
    }

    func trigger(_ input: EmptyWalletAction) {
        switch input {
        case .signUp:
            Router.route(to: RouteMap.Register.root(nil))
        case .signIn:
            Router.route(to: RouteMap.RestoreLogin.root)
        }
    }
}
