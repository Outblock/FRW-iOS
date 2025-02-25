//
//  WalletActionBar.swift
//  FRW
//
//  Created by Marty Ulrich on 2/24/25.
//

import SwiftUI

struct WalletActionBar<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        HStack {
            Group {
                content()
            }
            .maxWidth(.infinity)
        }
        .padding(.horizontal, 6)
    }
}
