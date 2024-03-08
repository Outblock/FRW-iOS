//
//  RouteableUIHostingController.swift
//  Flow Wallet
//
//  Created by Selina on 25/7/2022.
//

import SwiftUI
import UIKit

typealias RouteableView = View & RouterContentDelegate

protocol RouterContentDelegate {
    /// UINavigationBar use this to smooth push animation
    var title: String { get }
    
    /// UINavigationController use this to smooth push animation
    var isNavigationBarHidden: Bool { get }
    
    var navigationBarTitleDisplayMode: NavigationBarItem.TitleDisplayMode { get }
    
    /// Set If you want to force the colorScheme of the view
    var forceColorScheme: UIUserInterfaceStyle? { get }
    
    /// handle the back button action, default implementation is Router.pop()
    func backButtonAction()
    
    /// config navigation item
    func configNavigationItem(_ navigationItem: UINavigationItem)
}

extension RouterContentDelegate {
    var isNavigationBarHidden: Bool {
        return false
    }
    
    var navigationBarTitleDisplayMode: NavigationBarItem.TitleDisplayMode {
        return .inline
    }
    
    var forceColorScheme: UIUserInterfaceStyle? {
        return nil
    }
    
    func backButtonAction() {
        Router.pop()
    }
    
    func configNavigationItem(_ navigationItem: UINavigationItem) {
        
    }
}

class RouteableUIHostingController<Content: RouteableView>: UIHostingController<Content> {
    override init(rootView: Content) {
        super.init(rootView: rootView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        navigationItem.title = rootView.title
        
        if let style = rootView.forceColorScheme, style != .unspecified {
            self.overrideUserInterfaceStyle = style
        }
        
        let backItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(onBackButtonAction))
        backItem.tintColor = UIColor(named: "button.color")
        navigationItem.leftBarButtonItem = backItem
        
        navigationController?.navigationBar.prefersLargeTitles = rootView.navigationBarTitleDisplayMode == .large
        navigationItem.largeTitleDisplayMode = rootView.navigationBarTitleDisplayMode == .large ? .always : .never
        
        rootView.configNavigationItem(navigationItem)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let style = rootView.forceColorScheme, style != .unspecified {
            navigationController?.navigationBar.overrideUserInterfaceStyle = style
        }
        
        navigationController?.setNavigationBarHidden(rootView.isNavigationBarHidden, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let style = rootView.forceColorScheme, style != .unspecified {
            navigationController?.navigationBar.overrideUserInterfaceStyle = .unspecified
        }
    }
    
    @objc private func onBackButtonAction() {
        rootView.backButtonAction()
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
