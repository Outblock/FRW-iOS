//
//  Router.swift
//  Flow Wallet
//
//  Created by Selina on 25/7/2022.
//

import SwiftUI
import UIKit

protocol RouterTarget {
    func onPresent(navi: UINavigationController)
}

// MARK: - Public

extension Router {
    static func route(to target: RouterTarget) {
        safeMainThreadCall {
            if let navi = topNavigationController() {
                target.onPresent(navi: navi)
            }
        }
    }

    static func pop(animated: Bool = true) {
        safeMainThreadCall {
            if let navi = topNavigationController() {
                if let vc = navi.presentingViewController {
                    vc.dismiss(animated: animated)
                } else {
                    navi.popViewController(animated: animated)
                }
            } else {
                Router.dismiss(animated: animated)
            }
        }
    }

    static func popToRoot(animated: Bool = true) {
        safeMainThreadCall {
            if let navi = topNavigationController() {
                navi.popToRootViewController(animated: animated)
            }
        }
    }

    static func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        safeMainThreadCall {
            topPresentedController().presentingViewController?.dismiss(animated: animated, completion: completion)
        }
    }
}

// MARK: - Private

enum Router {
    static var coordinator = (UIApplication.shared.delegate as! AppDelegate).coordinator

    static func topPresentedController() -> UIViewController {
        var vc = coordinator.window.rootViewController
        while vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }

        return vc!
    }

    static func topNavigationController() -> UINavigationController? {
        if let navi = topPresentedController() as? UINavigationController {
            return navi
        }

        return coordinator.rootNavi
    }

    private static func safeMainThreadCall(_ call: @escaping () -> Void) {
        if Thread.isMainThread {
            call()
        } else {
            DispatchQueue.main.async {
                call()
            }
        }
    }
}
