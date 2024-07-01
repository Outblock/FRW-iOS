//
//  WallpaperView.swift
//  FRW
//
//  Created by cat on 2024/6/28.
//

import SwiftUI

struct WallpaperView: RouteableView {
    var title: String {
        return "Wallpaper"
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 8)
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 8) {
                Section {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(CardBackground.dynamicCases, id: \.identify) { card in
                            Card(cardBackgroud: card)
                        }
                    }
                } header: {
                    HStack {
                        Text("Dynamic")
                            .font(.inter(size: 14, weight: .semibold))
                            .foregroundStyle(Color.Theme.Text.black8)
                        Spacer()
                    }
                    .padding(.leading, 2)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }

                Section {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(0 ..< CardBackground.imageCases.count, id: \.self) { index in
                            let card = CardBackground.imageCases[index]
                            Card(cardBackgroud: card)
                        }
                    }
                } header: {
                    HStack {
                        Text("Static")
                            .font(.inter(size: 14, weight: .semibold))
                            .foregroundStyle(Color.Theme.Text.black8)
                        Spacer()
                    }
                    .padding(.leading, 2)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
            }
            .padding(.horizontal, 16)
        }
        .applyRouteable(self)
    }
}

extension WallpaperView {
    struct Card: View {
        var cardBackgroud: CardBackground
        
        @AppStorage("WalletCardBackrgound")
        private var walletCardBackrgound: String = "fade:0"
        
        var body: some View {
            ZStack(alignment: .topTrailing) {
                cardBackgroud.renderView()
                    .frame(height: 118)
            }
            .overlay(alignment: .topTrailing, content: {
                Image("wallpaper_check")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 16, height: 16)
                    .padding(8)
                    .visibility(walletCardBackrgound == cardBackgroud.rawValue ? .visible : .gone)
            })
            .frame(height: 118)
            .cornerRadius(8)
            .clipped()
            .onTapGesture {
                walletCardBackrgound = cardBackgroud.rawValue
//                Router.popToRoot()
            }
        }
    }
}

#Preview {
    WallpaperView()
}
