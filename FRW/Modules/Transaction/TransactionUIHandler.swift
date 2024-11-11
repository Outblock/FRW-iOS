//
//  TransactionUIHandler.swift
//  Flow Wallet
//
//  Created by Selina on 26/8/2022.
//

import UIKit

// MARK: - TransactionUIHandler

class TransactionUIHandler {
    // MARK: Lifecycle

    init() {
        addNotification()
    }

    // MARK: Internal

    static let shared = TransactionUIHandler()

    var window: UIWindow {
        Router.coordinator.window
    }

    // MARK: Private

    private lazy var panelHolder: TransactionHolderView = {
        let view = TransactionHolderView.createView()
        return view
    }()

    private lazy var listView: TransactionListView = {
        let view = TransactionListView()
        return view
    }()

    private func addNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onTransactionManagerChanged),
            name: .transactionManagerDidChanged,
            object: nil
        )
    }

    @objc
    private func onTransactionManagerChanged() {
        refreshPanelHolder()
    }
}

extension TransactionUIHandler {
    func showPanelHolder() {
        if panelHolder.superview == window {
            return
        }

        window.addSubview(panelHolder)
        panelHolder.show(inView: window)
    }

    func dismissPanelHolder() {
        if panelHolder.superview == nil {
            return
        }

        panelHolder.dismiss()
    }

    func refreshPanelHolder() {
        if TransactionManager.shared.holders.isEmpty {
            dismissPanelHolder()
            return
        }

        guard let model = TransactionManager.shared.holders.first else {
            return
        }
        panelHolder.config(model: model)
        showPanelHolder()
    }
}

extension TransactionUIHandler {
    func showListView() {
        if listView.superview == window {
            return
        }

        listView.frame = window.bounds
        listView.alpha = 0

        listView.refresh()

        window.addSubviews(listView)
        UIView.animate(withDuration: 0.25) {
            self.panelHolder.alpha = 0
            self.listView.alpha = 1
        }
    }

    func dismissListView() {
        if listView.superview == nil {
            return
        }

        UIView.animate(withDuration: 0.25) {
            self.panelHolder.alpha = 1
            self.listView.alpha = 0
        } completion: { _ in
            self.listView.removeFromSuperview()
        }
    }
}
