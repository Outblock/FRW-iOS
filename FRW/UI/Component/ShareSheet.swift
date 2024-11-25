//
//  ShareSheet.swift
//  Flow Wallet
//
//  Created by cat on 2022/6/6.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    // 你想分享的数据
    @Binding
    var items: [UIImage]

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)

        return controller
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
