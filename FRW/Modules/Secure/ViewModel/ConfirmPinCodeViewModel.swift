//
//  ConfirmPinCodeViewModel.swift
//  Flow Wallet
//
//  Created by Hao Fu on 10/1/22.
//

import SwiftUI

class ConfirmPinCodeViewModel: ViewModel {
    @Published var state: ConfirmPinCodeView.ViewState

    init(pin: String) {
        state = .init(lastPin: pin)
    }

    func trigger(_ input: ConfirmPinCodeView.Action) {
        switch input {
        case let .match(confirmPIN):
            if state.lastPin != confirmPIN {
                state.text = ""
                withAnimation(.default) {
                    state.pinCodeErrorTimes += 1
                }
                return
            }
            
            if !SecurityManager.shared.enablePinCode(confirmPIN) {
                HUD.error(title: "enable_pin_code_failed".localized)
                return
            }
            
            HUD.success(title: "pin_code_enabled".localized)
            
            DispatchQueue.main.async {
                if let navi = Router.topNavigationController(), let existVC = navi.viewControllers.first { $0.navigationItem.title == "security".localized } {
                    Router.route(to: RouteMap.Profile.security(true))
                } else {
                    Router.popToRoot()
                }
            }
        }
    }
}
