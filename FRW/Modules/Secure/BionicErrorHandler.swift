//
//  BionicErrorHandler.swift
//  Flow Wallet
//
//  Created by Selina on 4/8/2022.
//

import SwiftUI
import BiometricAuthentication

struct BionicErrorHandler {
    static func handleError(_ error: AuthenticationError) {
        switch error {
        case .biometryNotAvailable:
            HUD.error(title: "bionic_not_support".localized)
        case .biometryNotEnrolled:
            HUD.error(title: "no_bionic_enrolled".localized)
        case .biometryLockedout:
            HUD.error(title: "bionic_too_many_failed".localized)
        case .canceledByUser, .canceledBySystem:
            break
        default:
            HUD.error(title: error.localizedDescription)
            break
        }
    }
}
