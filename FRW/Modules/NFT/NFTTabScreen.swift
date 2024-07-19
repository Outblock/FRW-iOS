//
//  NFTTabScreen.swift
//  Flow Wallet
//
//  Created by Hao Fu on 16/1/22.
//

// Make sure you added this dependency to your project
// More info at https://bit.ly/CVPagingLayout
import CollectionViewPagingLayout
import IrregularGradient
import Kingfisher
import SwiftUI
import WebKit
import Lottie

extension NFTTabScreen: AppTabBarPageProtocol {
    static func tabTag() -> AppTabType {
        return .nft
    }

    static func iconName() -> String {
        "Grid"
    }

    static func color() -> SwiftUI.Color {
        return .LL.Secondary.mangoNFT
    }
}

struct NFTTabScreen: View {
    @StateObject var viewModel = NFTTabViewModel()

    @State var offset: CGFloat = 0

    @Namespace var NFTImageEffect

    let modifier = AnyModifier { request in
        var r = request
        r.setValue("APKAJYJ4EHJ62UVUHINA", forHTTPHeaderField: "CloudFront-Key-Pair-Id")
        return r
    }

    var body: some View {
        ZStack {
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundFill(Color.LL.Neutrals.background)
        .navigationBarHidden(true)
        .environmentObject(viewModel)
    }

    var content: some View {
        VStack(spacing: 0) {
            NFTUIKitListView(vm: viewModel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension NFTTabScreen {
    private enum Layout {
        static let menuHeight = 32.0
    }
}

// MARK: TopBar

extension NFTTabScreen {
    struct TopBar: View {
        @Binding var listStyle: NFTTabScreen.ViewStyle
        @Binding var offset: CGFloat

        @EnvironmentObject private var viewModel: NFTTabViewModel

        var body: some View {
            VStack(spacing: 0) {
                Spacer()
                
                HStack(alignment: .center) {
                    NFTSegmentControl(currentTab: $listStyle, styles: [.normal, .grid])
                    
                    Spacer()

                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding(8)
                            .background {
                                Circle()
                                    .foregroundColor(.LL.outline.opacity(0.8))
                            }
                    }
                }
                .frame(height: 44, alignment: .center)
                .padding(.horizontal, 18)
                .padding(.bottom, 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                Color.LL.Shades.front.opacity(offset < 0 ? abs(offset / 100.0) : 0)
            )
        }
    }
}

// MARK: Collection Bar

extension NFTTabScreen {
    struct CollectionBar: View {
        enum BarStyle {
            case horizontal
            case vertical

            mutating func toggle() {
                switch self {
                case .horizontal:
                    self = .vertical
                case .vertical:
                    self = .horizontal
                }
            }
        }

        @Binding var barStyle: NFTTabScreen.CollectionBar.BarStyle
        @Binding var listStyle: String

        var body: some View {
            VStack {
                if listStyle == "List" {
                    HStack {
                        Image(.Image.Logo.collection3D)
                        Text("collections".localized)
                            .font(.LL.largeTitle2)
                            .semibold()

                        Spacer()
                        Button {
                            barStyle.toggle()
                        } label: {
                            Image(barStyle == .horizontal ? .Image.Logo.gridHLayout : .Image.Logo.gridHLayout)
                        }
                    }
                    .foregroundColor(.LL.text)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                } else {
                    HStack {}
                        .frame(height: 0)
                }
            }
            .padding(.top, 36)
            .background(
                Color.LL.Neutrals.background
            )
        }
    }
}


// MARK: Preview

struct NFTTabScreen_Previews: PreviewProvider {
    static var previews: some View {
        NFTTabScreen()
    }
}
