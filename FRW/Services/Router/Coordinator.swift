//
//  Coordinator.swift
//  Flow Wallet
//
//  Created by Selina on 25/7/2022.
//

import Combine
import SwiftUI
import UIKit

// MARK: - AppTabType

// import Lottie

enum AppTabType {
    case wallet
    case nft
    case explore
    case profile
}

// MARK: - AppTabBarPageProtocol

protocol AppTabBarPageProtocol {
    static func tabTag() -> AppTabType
    static func iconName() -> String
    static func color() -> Color
}

// MARK: - Coordinator

final class Coordinator {
    // MARK: Lifecycle

    init(window: UIWindow) {
        self.window = window

        ThemeManager.shared.$style.sink { _ in
            DispatchQueue.main.async {
                self.refreshColorScheme()
            }
        }.store(in: &cancelSets)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    // MARK: Internal

    let window: UIWindow
    lazy var rootNavi: UINavigationController? = nil

    func showRootView() {
        if LocalUserDefaults.shared.onBoardingShown {
            showNormalView()
        } else {
            showOnBoardingView()
        }
    }

    // MARK: Private

    private lazy var privateView: AppPrivateView = {
        let view = AppPrivateView()
        return view
    }()

    private var cancelSets = Set<AnyCancellable>()
}

extension Coordinator {
    private func refreshColorScheme() {
        window.overrideUserInterfaceStyle = ThemeManager.shared.getUIKitStyle()
    }

    private func showOnBoardingView() {
        LocalUserDefaults.shared.onBoardingShown = true

        let view = OnBoardingView()
        let hostingView = UIHostingController(rootView: view)
        window.rootViewController = hostingView
    }

    private func showNormalView() {
        let rootView = SideContainerView()
        let hostingView = UIHostingController(rootView: rootView)
        let navi = RouterNavigationController(rootViewController: hostingView)
        navi.setNavigationBarHidden(true, animated: true)
        rootNavi = navi
        window.rootViewController = rootNavi

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            TransactionUIHandler.shared.refreshPanelHolder()
            PushHandler.shared.showPushAlertIfNeeded()
        }

//        #if DEBUG
//        LocalUserDefaults.shared.onBoardingShown = false
//        #endif
    }
}

// MARK: - Private Screen

extension Coordinator {
    @objc
    private func didEnterBackground() {
        privateView.alpha = 1
        privateView.removeFromSuperview()
        privateView.frame = window.bounds
        window.addSubview(privateView)
        privateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc
    private func didBecomeActive() {
        UIView.animate(withDuration: 0.25) {
            self.privateView.alpha = 0
        } completion: { _ in
            self.privateView.removeFromSuperview()
        }
    }
}
