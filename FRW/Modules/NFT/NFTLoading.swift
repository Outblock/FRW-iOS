//
//  NFTLoading.swift
//  Flow Wallet
//
//  Created by cat on 2022/5/19.
//

import SwiftUI

// MARK: - NFTLoading

struct NFTLoading: View {
    var body: some View {
        ZStack {
            Text("loading".localized)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - NFTLoading_Previews

struct NFTLoading_Previews: PreviewProvider {
    static var previews: some View {
        NFTLoading()
    }
}
