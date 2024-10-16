//
//  RouterNavigationController.swift
//  Flow Wallet
//
//  Created by Selina on 27/7/2022.
//

import UIKit

class RouterNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return childForStatusBarStyle?.preferredStatusBarStyle ?? .default
    }
}
