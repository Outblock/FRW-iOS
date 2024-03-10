//
//  RouterExtensions.swift
//  Flow Wallet
//
//  Created by Selina on 25/7/2022.
//

import SwiftUI
import UIKit

extension View {
    @ViewBuilder func applyRouteable(_ config: RouterContentDelegate) -> some View {
        navigationBarBackButtonHidden(true)
            .navigationBarHidden(config.isNavigationBarHidden)
            .navigationTitle(config.title)
            .navigationBarTitleDisplayMode(config.navigationBarTitleDisplayMode)
    }
}

extension UINavigationController {
    func push<T: RouteableView>(content: T, animated: Bool = true) {
        let vc = RouteableUIHostingController(rootView: content)
        self.pushViewController(vc, animated: animated)
    }
}

extension UIViewController {
    func present<T: RouteableView>(content: T, animated: Bool = true, wrapWithNavi: Bool = true) {
        let vc = RouteableUIHostingController(rootView: content)
        if wrapWithNavi {
            let navi = RouterNavigationController(rootViewController: vc)
            navi.modalPresentationCapturesStatusBarAppearance = true
            self.present(navi, animated: animated)
        } else {
            self.present(vc, animated: animated)
        }
    }
}
