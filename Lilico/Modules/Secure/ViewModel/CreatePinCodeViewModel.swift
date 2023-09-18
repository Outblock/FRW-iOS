//
//  CreatePinCodeViewModel.swift
//  Flow Reference Wallet
//
//  Created by Hao Fu on 10/1/22.
//

import Foundation


class CreatePinCodeViewModel: ViewModel {
    @Published
    private(set) var state: CreatePinCodeView.ViewState = .init()

    func trigger(_ input: CreatePinCodeView.Action) {
        switch input {
        case let .input(pin):
            if pin.count == 6 {
                Router.route(to: RouteMap.PinCode.confirmPinCode(pin))
            }
        }
    }
}
