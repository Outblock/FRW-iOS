//
//  TitleWithClosedView.swift
//  FRW
//
//  Created by cat on 2024/5/18.
//

import SwiftUI

struct TitleWithClosedView: View {
    var title: String
    var closeAction: () -> Void
    var body: some View {
        HStack {
            Color.clear
                .frame(width: 24, height: 24)
            Spacer()
            Text(title)
                .font(.inter(size: 24, weight: .bold))
                .foregroundStyle(Color.Theme.Text.black)
                .frame(height: 34)
                .padding(.top, 9)
            Spacer()
            Button {
                closeAction()
            } label: {
                HStack {
                    Image("icon_close_circle_gray")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
            }
        }
    }
}

#Preview {
    TitleWithClosedView(title: "Select NFTs", closeAction: {})
}
