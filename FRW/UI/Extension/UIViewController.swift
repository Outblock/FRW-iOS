//
//  UIViewController.swift
//  Flow Wallet
//
//  Created by Selina on 1/9/2022.
//

import UIKit
import SnapKit

extension UIViewController {
    func show(childViewController childVC: UIViewController, inView: UIView? = nil, useAutoLayout: Bool = true) {
        if let container = inView ?? self.view {
            addChild(childVC)
            container.addSubview(childVC.view)
            
            if useAutoLayout {
                childVC.view.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            } else {
                childVC.view.frame = container.bounds
            }
            
            childVC.didMove(toParent: self)
        }
    }
    
    func removeFromParentViewController() {
        self.willMove(toParent: nil)
        if view.superview != nil {
            view.removeFromSuperview()
        }
        self.removeFromParent()
    }
}
