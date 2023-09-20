//
//  NFTLoading.swift
//  Flow Reference Wallet
//
//  Created by cat on 2022/5/19.
//

import SwiftUI

struct NFTLoading: View {
    var body: some View {
        ZStack {
            Text("loading".localized)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NFTLoading_Previews: PreviewProvider {
    static var previews: some View {
        NFTLoading()
    }
}
