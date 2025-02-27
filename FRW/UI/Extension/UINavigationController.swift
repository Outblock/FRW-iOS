//
//  UINavigationController.swift
//  Flow Wallet
//
//  Created by Selina on 19/5/2022.
//

import Foundation
import UIKit

// TODO: Move to DI
struct UINavigationControllerState {
    static var shared = UINavigationControllerState()
    static let defaultState = true
    var allowsSwipeBack: Bool = true
}

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        guard UINavigationControllerState.shared.allowsSwipeBack else { return false }
        return viewControllers.count > 1
    }
}
