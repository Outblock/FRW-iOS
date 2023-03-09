//
//  NFTUIKitListView.swift
//  Lilico
//
//  Created by Selina on 11/8/2022.
//

import SwiftUI

struct NFTUIKitListView: UIViewControllerRepresentable {
    var vm: NFTTabViewModel
    
    func makeUIViewController(context: Context) -> NFTUIKitListViewController {
        let vc = NFTUIKitListViewController()
        vc.listStyleHandler.vm = vm
        vc.gridStyleHandler.vm = vm
        return vc
    }
    
    func updateUIViewController(_ uiViewController: NFTUIKitListViewController, context: Context) {
        
    }
}
