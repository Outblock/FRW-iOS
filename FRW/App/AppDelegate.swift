//
//  AppDelegate.swift
//  Flow Reference Wallet-lite
//
//  Created by Hao Fu on 12/12/21.
//

import Firebase
import FirebaseAnalytics
import Foundation
import GoogleSignIn
import Resolver
import SwiftUI
import UIKit
import WalletCore
import SwiftyBeaver
import FirebaseMessaging

#if DEBUG
import Atlantis
#endif

let log = SwiftyBeaver.self

@main
class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?
    lazy var coordinator = Coordinator(window: window!)
    
    static var isUnitTest : Bool {
#if DEBUG
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
#else
        return false
#endif
    }
    
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let _ = LocalEnvManager.shared
        
#if DEBUG
        let console = ConsoleDestination()
        console.format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M - $X"
        log.addDestination(console)
        
#endif
        
        FirebaseApp.configure()
        
        Analytics.setAnalyticsCollectionEnabled(true)
        Analytics.logEvent("ios_app_launch", parameters: [:])
        
        if !AppDelegate.isUnitTest {
            FirebaseConfig.start()
        }
        
        ServiceConfig.configure()
        
        appConfig()
        commonConfig()
        flowConfig()
        
        setupUI()
        tryToRestoreAccountWhenFirstLaunch()
        
#if DEBUG
        Atlantis.start()
#endif
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.jailbreakDetect()
        }
        
        return true
    }
    
    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        var parameters: [String: String] = [:]
        URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
            parameters[$0.name] = $0.value
        }
        
        if let filtered = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?
            .filter({ $0.name == "uri" && $0.value?.starts(with: "wc") ?? false }),
           let item = filtered.first, let uri = item.value {
            WalletConnectManager.shared.onClientConnected = {
                WalletConnectManager.shared.connect(link: uri)
            }
        }
        
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            if url.absoluteString.hasPrefix("https://fcw-link.lilico.app") {
                var uri = url.absoluteString.deletingPrefix("https://fcw-link.lilico.app/wc?uri=")
                uri = uri.deletingPrefix("fcw://")
                WalletConnectManager.shared.onClientConnected = {
                    WalletConnectManager.shared.connect(link: uri)
                }
                WalletConnectManager.shared.connect(link: uri)
                
            }
            else if url.absoluteString.hasPrefix("https://frw-link.lilico.app") {
                var uri = url.absoluteString.deletingPrefix("https://frw-link.lilico.app/wc?uri=")
                uri = uri.deletingPrefix("frw://")
                WalletConnectManager.shared.onClientConnected = {
                    WalletConnectManager.shared.connect(link: uri)
                }
                WalletConnectManager.shared.connect(link: uri)
                
            }
            else {
                var uri = url.absoluteString.deletingPrefix("https://link.lilico.app/wc?uri=")
                uri = uri.deletingPrefix("lilico://")
                WalletConnectManager.shared.onClientConnected = {
                    WalletConnectManager.shared.connect(link: uri)
                }
                WalletConnectManager.shared.connect(link: uri)
            }
        }
        return true
    }
}

// MARK: - Config

extension AppDelegate {
    private func setupNavigationBar() {
        let font = UIFont(name: "Inter", size: 18)?.semibold
        let largeFont = UIFont(name: "Inter", size: 24)?.bold
        let color = UIColor(named: "neutrals.text")!
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: color, .font: font!]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: color, .font: largeFont!]
    }
    
    private func appConfig() {
        MultiAccountStorage.shared.upgradeFromOldVersionIfNeeded()
        
        _ = UserManager.shared
        _ = WalletManager.shared
        _ = BackupManager.shared
        _ = SecurityManager.shared
        _ = WalletConnectManager.shared
        _ = CoinRateCache.cache
        if !AppDelegate.isUnitTest {
            _ = RemoteConfigManager.shared
        }
        _ = StakingManager.shared
        
        _ = ChildAccountManager.shared
        WalletManager.shared.bindChildAccountManager()
        NFTCatalogCache.cache.fetchIfNeed()
    }
    
    private func commonConfig() {
        setupNavigationBar()
        
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().sectionHeaderTopPadding = 0
        UISearchBar.appearance().tintColor = UIColor.LL.Secondary.violetDiscover
        UINavigationBar.appearance().shadowImage = UIImage()
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .orange
        
        HUD.setupProgressHUD()
    }
    
    private func flowConfig() {
        FlowNetwork.setup()
    }
    
    private func tryToRestoreAccountWhenFirstLaunch() {
        if LocalUserDefaults.shared.tryToRestoreAccountFlag {
            // has been triggered or no old account to restore
            return
        }
        
        self.window?.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.window?.isUserInteractionEnabled = true
            UserManager.shared.tryToRestoreOldAccountOnFirstLaunch()
        }
    }
}

// MARK: - UI

extension AppDelegate {
    private func setupUI() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNetworkChange), name: .networkChange, object: nil)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.LL.Neutrals.background
        
        coordinator.showRootView()
        coordinator.rootNavi?.view.alpha = 0
        
        self.window?.makeKeyAndVisible()
        
        SecurityManager.shared.lockAppIfNeeded()
        
        UIView.animate(withDuration: 0.2, delay: 0.1) {
            self.coordinator.rootNavi?.view.alpha = 1
        }
        
        delay(.seconds(5)) {
            UIView.animate(withDuration: 0.2) {
                self.window?.backgroundColor = currentNetwork.isMainnet ? UIColor.LL.Neutrals.background : UIColor(currentNetwork.color)
            }
        }
    }
    
    @objc func handleNetworkChange() {
        self.window?.backgroundColor = currentNetwork.isMainnet ? UIColor.LL.Neutrals.background : UIColor(currentNetwork.color)
    }
}

extension AppDelegate {
    private func jailbreakDetect() {
        if UIDevice.isJailbreak {
            Router.route(to: RouteMap.Wallet.jailbreakAlert)
        }
    }
}
