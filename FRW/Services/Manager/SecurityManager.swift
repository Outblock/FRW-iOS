//
//  SecurityManager.swift
//  Flow Wallet
//
//  Created by Selina on 4/8/2022.
//

import BiometricAuthentication
import KeychainAccess
import SwiftUI

extension SecurityManager {
    enum SecurityType: Int {
        case none
        case pin
        case bionic
        case both
    }

    enum BionicType {
        case none
        case faceid
        case touchid

        // MARK: Internal

        var desc: String {
            switch self {
            case .none:
                return ""
            case .faceid:
                return "face_id".localized
            case .touchid:
                return "touch_id".localized
            }
        }
    }
}

// MARK: - SecurityManager

class SecurityManager {
    // MARK: Lifecycle

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    // MARK: Internal

    static let shared = SecurityManager()

    var isLocked: Bool = false

    var securityType: SecurityType {
        LocalUserDefaults.shared.securityType
    }

    // MARK: Private

    private let PinCodeKey = "PinCodeKey"
    private var ignoreOnce: Bool = false

    @objc
    private func onEnterBackground() {
        lockAppIfNeeded()
    }
}

// MARK: - Lock

extension SecurityManager {
    var isLockOnExitEnabled: Bool {
        LocalUserDefaults.shared.lockOnExit
    }

    func changeLockOnExistStatus(_ lock: Bool) {
        LocalUserDefaults.shared.lockOnExit = lock
    }

    func lockAppIfNeeded() {
        if !isLockOnExitEnabled {
            return
        }

        if isLocked {
            return
        }

        if securityType == .none {
            return
        }

        isLocked = true
        Router.route(to: RouteMap.PinCode.verify(false, false) { [weak self] result in
            if result {
                self?.isLocked = false
                Router.dismiss()
            }
        })
    }

    func inAppVerify() async -> Bool {
        await withCheckedContinuation { continuation in
            Router.route(to: RouteMap.PinCode.verify(true, true) { result in
                Router.dismiss()
                continuation.resume(returning: result)
            })
        }
    }

    func openIgnoreOnce() {
        ignoreOnce = true
    }

    func SecurityVerify() async -> Bool {
        guard !ignoreOnce else {
            ignoreOnce = false
            log.info("[security] ignore once")
            return true
        }
        guard securityType != .none else {
            return true
        }
        return await withCheckedContinuation { continuation in
            Router.route(to: RouteMap.PinCode.verify(true, true) { result in
                Router.dismiss {
                    continuation.resume(returning: result)
                }
            })
        }
    }
}

// MARK: - Pin Code

extension SecurityManager {
    var isPinCodeEnabled: Bool {
        securityType == .pin || securityType == .both
    }

    var currentPinCode: String {
        guard let code = try? WalletManager.shared.mainKeychain.getString(PinCodeKey) else {
            return ""
        }

        return code
    }

    func enablePinCode(_ code: String) -> Bool {
        if !updatePinCode(code) {
            return false
        }

        appendSecurity(type: .pin)
        return true
    }

    func disablePinCode() -> Bool {
        if !isPinCodeEnabled {
            return true
        }

        if !updatePinCode("") {
            return false
        }

        removeSecurity(type: .pin)
        return true
    }

    func updatePinCode(_ code: String) -> Bool {
        do {
            try WalletManager.shared.mainKeychain.set(code, key: PinCodeKey)
            return true
        } catch {
            debugPrint("SecurityManager -> updatePinCode(): failed: \(error)")
            return false
        }
    }

    func authPinCode(_ code: String) -> Bool {
        currentPinCode == code
    }
}

// MARK: - Bionic

extension SecurityManager {
    var isBionicEnabled: Bool {
        securityType == .bionic || securityType == .both
    }

    var supportedBionic: SecurityManager.BionicType {
        if BioMetricAuthenticator.shared.faceIDAvailable() {
            return .faceid
        }

        if BioMetricAuthenticator.shared.touchIDAvailable() {
            return .touchid
        }

        return .none
    }

    func enableBionic() async -> Bool {
        let result = await authBionic()
        if !result {
            return false
        }

        DispatchQueue.syncOnMain {
            self.appendSecurity(type: .bionic)
        }

        return true
    }

    func disableBionic() {
        if !isBionicEnabled {
            return
        }

        removeSecurity(type: .bionic)
    }

    func authBionic() async -> Bool {
        await withCheckedContinuation { continuation in
            BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { result in
                switch result {
                case .success:
                    continuation.resume(returning: true)
                case let .failure(error):
                    BionicErrorHandler.handleError(error)
                    continuation.resume(returning: false)
                }
            }
        }
    }
}

// MARK: - Security Type Config

extension SecurityManager {
    private func appendSecurity(type: SecurityType) {
        let currentType = securityType

        if currentType == .both {
            return
        }

        if currentType == type {
            return
        }

        switch currentType {
        case .none:
            LocalUserDefaults.shared.securityType = type
        default:
            LocalUserDefaults.shared.securityType = .both
        }
    }

    private func removeSecurity(type: SecurityType) {
        if type == .none {
            return
        }

        let currentType = securityType

        if currentType == type {
            LocalUserDefaults.shared.securityType = .none
            return
        }

        if currentType == .both {
            if type == .pin {
                LocalUserDefaults.shared.securityType = .bionic
            } else if type == .bionic {
                LocalUserDefaults.shared.securityType = .pin
            }
        }
    }
}
