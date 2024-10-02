//
//  BrowserViewController.swift
//  Flow Wallet
//
//  Created by Selina on 1/9/2022.
//

import Combine
import Hero
import SnapKit
import SwiftUI
import TrustWeb3Provider
import UIKit
import WebKit

class BrowserViewController: UIViewController {
    private var observation: NSKeyValueObservation?
    private var actionBarIsHiddenFlag: Bool = false
    public var shouldHideActionBar: Bool = false
    private var cancelSets = Set<AnyCancellable>()
    
    let trustProvider = TrustWeb3Provider.flowConfig()

    private var commonColor: UIColor? =  UIColor(named: "bg.silver")
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = commonColor
        return view
    }()
    
    private lazy var bgMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    lazy var webView: WKWebView = {
        let view = WKWebView(frame: .zero, configuration: generateWebViewConfiguration())
        view.navigationDelegate = self
        view.uiDelegate = self
        view.backgroundColor = commonColor
        view.scrollView.backgroundColor = commonColor
        view.allowsBackForwardNavigationGestures = true
        view.allowsLinkPreview = true
        view.layer.masksToBounds = true
        #if DEBUG
            if #available(iOS 16.4, *) {
                view.isInspectable = true
            }
        #endif
        return view
    }()
    
    lazy var jsHandler: JSMessageHandler = {
        let obj = JSMessageHandler()
        obj.webVC = self
        return obj
    }()
    
    lazy var trustJSHandler: TrustJSMessageHandler = {
        let obj = TrustJSMessageHandler()
        obj.webVC = self
        return obj
    }()
    
    private lazy var actionBarView: BrowserActionBarView = {
        let view = BrowserActionBarView()
        
        view.backBtn.addTarget(self, action: #selector(onBackBtnClick), for: .touchUpInside)
        view.homeBtn.addTarget(self, action: #selector(onHomeBtnClick), for: .touchUpInside)
        view.moveBtn.addTarget(self, action: #selector(onMoveAssets), for: .touchUpInside)
        view.reloadBtn.addTarget(self, action: #selector(onReloadBtnClick), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onAddressBarClick))
        view.addressBarContainer.addGestureRecognizer(tapGesture)
        
        view.bookmarkAction = { [weak self] isBookmark in
            guard let self = self else { return }
            self.onBookmarkAction(isBookmark)
        }
        view.clearCookie = { [weak self] in
            guard let self = self else { return }
            self.onClearCookie()
        }
        
        return view
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        observation = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupObserver()
        hero.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadBgPaths()
    }
    
    private func setup() {
        view.backgroundColor = commonColor
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
        }
        
        contentView.layer.mask = bgMaskLayer
        
        setupWebView()
        setupActionBarView()
    }
    
    private func setupWebView() {
        contentView.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        webView.scrollView.delegate = self
    }
    
    private func setupActionBarView() {
        contentView.addSubview(actionBarView)
        actionBarView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(webView.snp.bottom).offset(0)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupObserver() {
        observation = webView.observe(\.estimatedProgress, options: .new, changeHandler: { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.reloadActionBarView()
            }
        })
        
        NotificationCenter.default.publisher(for: .networkChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.onReloadBtnClick()
            }.store(in: &cancelSets)
    }
    
    private func reloadBgPaths() {
        bgMaskLayer.frame = contentView.bounds
        
        let path = UIBezierPath(roundedRect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20.0, height: 20.0))
        bgMaskLayer.path = path.cgPath
    }
}

// MARK: - Load

extension BrowserViewController {
    func loadURL(_ url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

// MARK: - Action Bar

extension BrowserViewController {
    private func reloadActionBarView() {
        if let title = webView.title, !title.isEmpty {
            actionBarView.addressLabel.text = title
        } else {
            actionBarView.addressLabel.text = webView.url?.absoluteString
        }
        
        actionBarView.moveBtn.isSelected = webView.isLoading
        actionBarView.reloadBtn.isSelected = webView.isLoading
        actionBarView.progressView.isHidden = !webView.isLoading
        actionBarView.progressView.progress = webView.isLoading ? webView.estimatedProgress : 0
        
        actionBarView.updateMenu(currentURL: webView.url)
    }
    
    private func hideActionBarView() {
//        if actionBarIsHiddenFlag {
//            return
//        }
//        
//        actionBarIsHiddenFlag = true
//        
//        UIView.animate(withDuration: 0.25) {
//            let y = Router.coordinator.window.safeAreaInsets.bottom + 20 + BrowserActionBarViewHeight
//            self.actionBarView.transform = CGAffineTransform(translationX: 0, y: y)
//        }
    }
    
    private func showActionBarView() {
//        if !actionBarIsHiddenFlag {
//            return
//        }
//        
//        actionBarIsHiddenFlag = false
//        
//        UIView.animate(withDuration: 0.25) {
//            self.actionBarView.transform = .identity
//        }
    }
    
    @objc private func onBackBtnClick() {
        if webView.canGoBack {
            webView.goBack()
            return
        }
        
        onHomeBtnClick()
    }
    
    @objc private func onHomeBtnClick() {
        Router.pop()
    }
    
    @objc private func onReloadBtnClick() {
        webView.reload()
    }
    
    @objc private func onMoveAssets() {
        if MoveAssetsAction.shared.allowMoveAssets {
            let vc = PresentHostingController(rootView: MoveAssetsView())
            self.navigationController?.present(vc, completion: nil)
        }else {
            HUD.info(title: "Features Coming Soon")
        }
    }
    
    @objc private func onAddressBarClick() {
        showSearchInputView()
    }
    
    private func onBookmarkAction(_ isBookmark: Bool) {
        guard let url = webView.url else {
            return
        }
        
        if isBookmark {
            let bookmark = WebBookmark()
            bookmark.url = url.absoluteString
            bookmark.title = webView.title ?? "bookmark"
            bookmark.createTime = Date().timeIntervalSince1970
            bookmark.updateTime = bookmark.createTime
            DBManager.shared.save(webBookmark: bookmark)
            HUD.success(title: "browser_bookmark_added".localized)
        } else {
            DBManager.shared.delete(webBookmarkByURL: url.absoluteString)
            HUD.success(title: "browser_bookmark_deleted".localized)
        }
        
        actionBarView.updateMenu(currentURL: webView.url)
    }
    
    private func onClearCookie() {
        BrowserViewController.deleteCookie()
    }
}

// MARK: - Search Recommend

extension BrowserViewController {
    private func showSearchInputView() {
        let inputVC = BrowserSearchInputViewController()
        inputVC.setSearchText(text: webView.url?.absoluteString)
        inputVC.selectTextCallback = { [weak self] text in
            let urlString = BrowserSearchInputViewController.makeUrlIfNeeded(urlString: text)
            if let url = URL(string: urlString) {
                self?.navigationController?.popViewController(animated: false) {
                    self?.loadURL(url)
                }
            }
        }
        navigationController?.pushViewController(inputVC, animated: false)
    }
}

// MARK: - Delegate

extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        reloadActionBarView()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        reloadActionBarView()
        
        // For some website there is a overlapping,
        // hence we hide the tool bar at the begining.
        if shouldHideActionBar {
            hideActionBarView()
            shouldHideActionBar = false
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        reloadActionBarView()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        reloadActionBarView()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        reloadActionBarView()
    }
    
}

extension BrowserViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
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
            else if url.absoluteString.hasPrefix("https://link.lilico.app") {
                var uri = url.absoluteString.deletingPrefix("https://link.lilico.app/wc?uri=")
                uri = uri.deletingPrefix("lilico://")
                WalletConnectManager.shared.onClientConnected = {
                    WalletConnectManager.shared.connect(link: uri)
                }
                WalletConnectManager.shared.connect(link: uri)
            }else if url.description.lowercased().range(of: "http://") != nil ||
                url.description.lowercased().range(of: "https://") != nil ||
                url.description.lowercased().range(of: "mailto:") != nil
            {
                UIApplication.shared.openURL(url)
            }
        }
        
        return nil
    }
}

extension BrowserViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if translation.y >= 0 {
            showActionBarView()
        } else {
            hideActionBarView()
        }
    }
}

extension BrowserViewController {
    static func deleteCookie() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        let dispatch_group = DispatchGroup()
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                dispatch_group.enter()
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {
                    dispatch_group.leave()
                })
                #if DEBUG
                    print("WKWebsiteDataStore record deleted:", record)
                #endif
            }
            dispatch_group.notify(queue: DispatchQueue.main) {}
        }
    }
}
