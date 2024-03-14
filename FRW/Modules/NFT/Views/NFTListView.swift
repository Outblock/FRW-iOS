//
//  NFTListView.swift
//  Flow Wallet
//
//  Created by cat on 2022/5/30.
//

import SwiftUI
import Kingfisher

struct RefreshableView<Content: View>: View {
    
    var content: () -> Content
    
    @Environment(\.refresh) private var refresh   // << refreshable injected !!
    @State private var isRefreshing = false

    var body: some View {
        VStack {
            if isRefreshing {
                MyProgress()    // ProgressView() ?? - no, it's boring :)
                    .transition(.scale)
            }
            content()
        }
        .animation(.default, value: isRefreshing)
        .background(GeometryReader {
            // detect Pull-to-refresh
            Color.clear.preference(key: ViewOffsetKey.self, value: -$0.frame(in: .global).origin.y)
        })
        .onPreferenceChange(ViewOffsetKey.self) {
            if $0 < -80 && !isRefreshing {   // << any creteria we want !!
                isRefreshing = true
                Task {
                    await refresh?()           // << call refreshable !!
                    await MainActor.run {
                        isRefreshing = false
                    }
                }
            }
        }
    }
}

struct MyProgress: View {
    @State private var isProgress = false
    var body: some View {
        HStack{
             ForEach(0...4, id: \.self){index in
                  Circle()
                        .frame(width:10,height:10)
                        .foregroundColor(.red)
                        .scaleEffect(self.isProgress ? 1:0.01)
                        .animation(self.isProgress ? Animation.linear(duration:0.6).repeatForever().delay(0.2*Double(index)) :
                             .default
                        , value: isProgress)
             }
        }
        .onAppear { isProgress = true }
        .padding()
    }
}

private struct ViewOffsetKey: PreferenceKey {
    public typealias Value = CGFloat
    public static var defaultValue = CGFloat.zero
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct NFTListView: View {
    var list: [NFTModel]
    var imageEffect: Namespace.ID
    var fromLinkedAccount: Bool = false

    @EnvironmentObject private var viewModel: NFTTabViewModel

    private let nftLayout: [GridItem] = [
        GridItem(.adaptive(minimum: 130), spacing: 18),
        GridItem(.adaptive(minimum: 130), spacing: 18),
    ]

    var body: some View {
        VStack {
            LazyVGrid(columns: nftLayout, alignment: .center) {
                ForEach(list, id: \.self) { nft in
                    NFTSquareCard(nft: nft, imageEffect: imageEffect) { model in
                        viewModel.trigger(.info(model, fromLinkedAccount))
                    }
                    .frame(height: ceil((screenWidth - 18 * 3) / 2 + 50))
                }
            }
            .padding(EdgeInsets(top: 12, leading: 18, bottom: 30, trailing: 18))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.LL.Shades.front
        )
        .cornerRadius(16)
    }

    func repairHeight() -> CGFloat {
        if list.count < 4 {
            return 200.0
        }
        return 0.0
    }
}

struct NFTListView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        NFTListView(list: [], imageEffect: namespace)
            .environmentObject(NFTTabViewModel())
    }
}
