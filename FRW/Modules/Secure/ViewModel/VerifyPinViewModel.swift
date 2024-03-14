//
//  VerifyPinViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 3/8/2022.
//

import SwiftUI
import BiometricAuthentication
import UIKit

extension VerifyPinViewModel {
    typealias VerifyCallback = (Bool) -> ()
    
    enum VerifyType {
        case pin
        case bionic
    }
}

class VerifyPinViewModel: ObservableObject {
    @Published var currentVerifyType: VerifyPinViewModel.VerifyType = .pin
    @Published var inputPin: String = ""
    @Published var pinCodeErrorTimes: Int = 0
    var callback: VerifyCallback? = nil
    private lazy var generator: UINotificationFeedbackGenerator = {
        let obj = UINotificationFeedbackGenerator()
        return obj
    }()
    
    private var isBionicVerifing: Bool = false
    private var canVerifyBionicAutomatically = true
    
    init(callback: VerifyCallback?) {
        self.callback = callback
        
        let type = SecurityManager.shared.securityType
        switch type {
        case .both, .bionic:
            currentVerifyType = .bionic
        case .pin:
            currentVerifyType = .pin
        default:
            break
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onAppBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func onAppBecomeActive() {
        if currentVerifyType == .bionic, isBionicVerifing == false, canVerifyBionicAutomatically == true {
            verifyBionicAction()
        }
    }
}

extension VerifyPinViewModel {
    func changeVerifyTypeAction(type: VerifyPinViewModel.VerifyType) {
        if currentVerifyType != type {
            currentVerifyType = type
        }
    }
    
    func verifyPinAction() {
        let result = SecurityManager.shared.authPinCode(inputPin)
        if !result {
            pinVerifyFailed()
            return
        }
        
        verifySuccess()
    }
    
    private func pinVerifyFailed() {
        generator.notificationOccurred(.error)
        
        inputPin = ""
        withAnimation(.default) {
            pinCodeErrorTimes += 1
        }
    }
    
    func verifyBionicAction() {
        if isBionicVerifing {
            return
        }
        
        if UIApplication.shared.applicationState != .active {
            return
        }
        
        isBionicVerifing = true
        canVerifyBionicAutomatically = false
        
        Task {
            let result = await SecurityManager.shared.authBionic()
            DispatchQueue.main.async {
                self.isBionicVerifing = false
                
                if result {
                    self.verifySuccess()
                }
            }
        }
    }
    
    private func verifySuccess() {
        if let customCallback = callback {
            customCallback(true)
        }
    }
}
