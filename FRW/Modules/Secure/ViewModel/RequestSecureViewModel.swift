//
//  RequestSecureViewModel.swift
//  Flow Wallet
//
//  Created by Hao Fu on 10/1/22.
//

import BiometricAuthentication
import Foundation

class RequestSecureViewModel: ViewModel {
    // MARK: Lifecycle

    init() {
        if BioMetricAuthenticator.shared.faceIDAvailable() {
            // device supports face id recognition.
            state = .init(biometric: .faceId)
        }

        if BioMetricAuthenticator.shared.touchIDAvailable() {
            // device supports touch id authentication
            state = .init(biometric: .touchId)
        }

        if !BioMetricAuthenticator.canAuthenticate() {
            state = .init(biometric: .none)
        }
    }

    // MARK: Internal

    @Published
    private(set) var state: RequestSecureView.ViewState = .init()

    func trigger(_ input: RequestSecureView.Action) {
        switch input {
        case .faceID:
            BioMetricAuthenticator
                .authenticateWithBioMetrics(reason: "Need your permission") { result in
                    switch result {
                    case .success:
                        Router.popToRoot()
                    case let .failure(error):
                        print("Authentication Failed")
                        print(error)
                    }
                }
        case .pin:
            Router.route(to: RouteMap.PinCode.pinCode)
        }
    }
}
