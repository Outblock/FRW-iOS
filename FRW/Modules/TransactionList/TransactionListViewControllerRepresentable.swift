//
//  TransactionListViewControllerRepresentable.swift
//  FRW
//
//  Created by Marty Ulrich on 2/10/25.
//

import SwiftUI

struct TransactionListViewControllerRepresentable: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = TransactionListViewController()
        let nav = UINavigationController(rootViewController: vc)
        return nav
    }
}
