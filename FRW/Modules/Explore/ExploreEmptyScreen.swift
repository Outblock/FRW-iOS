//
//  ExploreEmptyScreen.swift
//  Flow Wallet
//
//  Created by Hao Fu on 16/9/2022.
//

import SwiftUI

struct ExploreEmptyScreen: View {
    var body: some View {
        VStack(alignment: .center) {
            Image("empty-box")
            
            Text("Empty Bookmarks")
                .font(.LL.body)
                .fontWeight(.medium)
                .foregroundColor(.LL.Neutrals.neutrals9)
        }
        .background(.LL.Neutrals.background)
    }
}

struct ExploreEmptyScreen_Previews: PreviewProvider {
    static var previews: some View {
        ExploreEmptyScreen()
    }
}
