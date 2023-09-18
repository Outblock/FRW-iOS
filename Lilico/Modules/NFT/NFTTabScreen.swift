//
//  NFTTabScreen.swift
//  Flow Reference Wallet
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
//            NFTTabScreen.TopBar(listStyle: $viewModel.state.style, offset: $offset)
            NFTUIKitListView(vm: viewModel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
//        GeometryReader { _ in
//            ZStack(alignment: .top) {
//                if !viewModel.state.isEmpty {
//                    OffsetScrollView(offset: $offset, refreshEnabled: true, loadMoreEnabled: true, refreshCallback: {
//                        viewModel.refreshCollectionAction(isFromCache: false)
//                    }, loadMoreCallback: {
//                        viewModel.loadCurrentCollectionItemMoreDataAction()
//                    }, isNoData: viewModel.currentCollectionItem()?.isEnd ?? true) {
//                        //TODO: if no like
//                        Color.clear
//                            .frame(height: statusHeight)
//                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
//                            if isListStyle {
//                                if canShowFavorite {
//                                    NFTTabScreen.FavoriteView(currentNFTImage: $currentNFTImage)
//                                }
//
//                                Section {
//                                    if isHorizontalCollection {
//                                        NFTListView(list: currentNFTs, imageEffect: NFTImageEffect)
//
//                                    }
//                                } header: {
//                                    NFTTabScreen.CollectionSection(listStyle: $listStyle, isHorizontal: $isHorizontalCollection, selectedIndex: $viewModel.state.selectedIndex)
//                                }
//                            } else {
//                                NFTListView(list: currentNFTs, imageEffect: NFTImageEffect)
//                                    .padding(.top,  44)
//                            }
//                        }
//                    }
//                    .overlay(
//                        NFTTabScreen.TopBar(listStyle: $listStyle, offset: $offset)
//                            .frame(maxHeight: .infinity, alignment: .top)
//                            .padding(.top, statusHeight)
//                    )
//                    .background(
//                        Color.LL.Neutrals.background
//                    )
//                }
//            }
//
//        }
    }

    var statusHeight: CGFloat {
        let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        lazy var statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        return statusBarHeight
    }
}

extension NFTTabScreen {
    private enum Layout {
        static let menuHeight = 32.0
    }
}

// MARK: FavoriteView

extension NFTTabScreen {
//    struct FavoriteView: View {
//        @Binding
//        var currentNFTImage: URL?
//
//        @EnvironmentObject private var viewModel: NFTTabViewModel
//        @StateObject
//        var favoriteStore = NFTFavoriteStore.shared
//        @State var favoriteId: String?
//
//        var body: some View {
//            VStack(spacing: 0) {
//                if favoriteStore.favorites.count > 0 {
//                    VStack(alignment: .center, spacing: 0) {
//                        HStack(spacing: 8) {
//                            Image(systemName: "star.fill")
//                            Text("top_selection".localized)
//                                .font(.LL.largeTitle2)
//                                .semibold()
//
//                            Spacer()
//                        }
//                        .frame(height: 32)
//                        .padding(.horizontal, 18)
//                        .foregroundColor(.LL.Shades.front)
//
//                        StackPageView(favoriteStore.favorites, selection: $favoriteId) { nft in
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 16)
//                                    .fill(Color.LL.background)
//                                KFImage
//                                    .url(nft.image)
//                                    .placeholder({
//                                        Image("placeholder")
//                                            .resizable()
//                                    })
//                                    .fade(duration: 0.25)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .frame(width: imageHeight,
//                                           height: imageHeight)
//                                    .cornerRadius(8)
//                                    .clipped()
//                            }
//                            .frame(width: imageHeight + 24,
//                                   height: imageHeight + 24)
//                            .onTapGesture {
//                                onTapNFT()
//                            }
//                        }
//                        .options(options)
//                        .pagePadding(
//                            top: .absolute(0),
//                            left: .absolute(18),
//                            bottom: .absolute(0),
//                            right: .fractionalWidth(0.24)
//                        )
//                        .frame(width: screenWidth,
//                               height: imageHeight + 12, alignment: .center)
//                        .padding(.top, 16)
//                    }
//                    .padding(.top, 48)
//                    .background(
//                        ZStack {
//                            if let url = currentNFTImage?.absoluteString, let colors = viewModel.state.colorsMap[url] {
//                                if colors.count > 0 {
//                                    NFTBlurImageView(colors: colors)
////                                        .irregularGradient(colors: colors)
//                                }
//                            }
//                        }
//                    )
//                    .onChange(of: favoriteId) { _ in
//                        guard let favoriteId = favoriteId, let nft = favoriteStore.find(with: favoriteId) else {
//                            let model = favoriteStore.favorites.first
//                            currentNFTImage = model?.image
//                            return
//                        }
//                        currentNFTImage = nft.image
//                        if let url = currentNFTImage?.absoluteString {
//                            viewModel.trigger(.fetchColors(url))
//                        }
//                    }
//                }
//            }
//
//            .onAppear {
//                if favoriteId == nil {
//                    favoriteId = favoriteStore.favorites.first?.id
//                }
//            }
//        }
//
//        var imageHeight: CGFloat {
//            return (screenWidth * 0.76 - 18 - 24)
//        }
//
//        var options = StackTransformViewOptions(
//            scaleFactor: 0.10,
//            minScale: 0.0,
//            maxScale: 0.95,
//            maxStackSize: 6,
//            spacingFactor: 0.1,
//            maxSpacing: nil,
//            alphaFactor: 0.00,
//            bottomStackAlphaSpeedFactor: 0.90,
//            topStackAlphaSpeedFactor: 0.30,
//            perspectiveRatio: 0.30,
//            shadowEnabled: true,
//            shadowColor: Color.LL.rebackground.toUIColor()!,
//            shadowOpacity: 0.10,
//            shadowOffset: .zero,
//            shadowRadius: 5.00,
//            stackRotateAngel: 0.00,
//            popAngle: 0.31,
//            popOffsetRatio: .init(width: -1.45, height: 0.30),
//            stackPosition: .init(x: 1.00, y: 0.00),
//            reverse: false,
//            blurEffectEnabled: false,
//            maxBlurEffectRadius: 0.00,
//            blurEffectStyle: .light
//        )
//
//        func onTapNFT() {
//            guard let favoriteId = favoriteId, let nft = favoriteStore.find(with: favoriteId) else {
//                return
//            }
//            viewModel.trigger(.info(nft))
//        }
//    }
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

extension NFTTabScreen {
//    struct CollectionSection: View {
//
//        @Binding var listStyle: String
//        @Binding var isHorizontal: Bool
//        @Binding var selectedIndex: Int
//        @EnvironmentObject var viewModel: NFTTabViewModel
//
//        var body: some View {
//            VStack {
//                if listStyle == "List" {
//                    VStack {
//                        HStack {
//                            Image(.Image.Logo.collection3D)
//                            Text("collections".localized)
//                                .font(.LL.largeTitle2)
//                                .semibold()
//
//                            Spacer()
//                            Button {
//                                isHorizontal.toggle()
//                            } label: {
//                                Image( isHorizontal ? .Image.Logo.gridHLayout : .Image.Logo.gridHLayout)
//                            }
//                        }
//                        .foregroundColor(.LL.text)
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 16)
//                        .padding(.top, 22)
//
//                        VStack {
//                            if isHorizontal {
//                                ScrollViewReader { proxy in
//                                    ScrollView(.horizontal,
//                                               showsIndicators: false,
//                                               content: {
//                                                   LazyHStack(alignment: .center, spacing: 12, content: {
//                                                       ForEach(viewModel.state.items, id: \.id) { item in
//                                                           let index = viewModel.state.items.firstIndex(where: {$0.id == item.id})!
//                                                           NFTCollectionCard(index: index, item: item, isHorizontal: true, selectedIndex: $selectedIndex)
//                                                               .id(index)
//                                                               .onChange(of: selectedIndex) { value in
//                                                                   withAnimation {
//                                                                       proxy.scrollTo(value, anchor: .center)
//                                                                   }
//                                                               }
//                                                       }
//                                                   })
//                                                   .frame(height: 56)
//                                                   .padding(.leading, 18)
//                                                   .padding(.bottom, 12)
//
//                                               })
//                                }
//                            } else {
//                                LazyVStack(alignment: .center, spacing: 12, content: {
//                                    ForEach(viewModel.state.items, id: \.id) { item in
//                                        let index = viewModel.state.items.firstIndex(where: {$0.id == item.id})!
//                                        NFTCollectionCard(index: index, item: item, isHorizontal: false, selectedIndex: $selectedIndex)
//                                    }
//                                })
//                                .padding(.horizontal, 18)
//                            }
//                        }
//                    }
//
//                }
//            }
//            .background(
//                Color.LL.Neutrals.background
//            )
//        }
//    }
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

// MARK: Collection Section

extension NFTTabScreen {
//    struct CollectionBody: View {
//        @Binding var barStyle: NFTTabScreen.CollectionBar.BarStyle
//        @Binding var selectedIndex: Int
//        @EnvironmentObject var viewModel: NFTTabViewModel
//
//        var body: some View {
//            VStack {
//                if barStyle == .horizontal {
//                    ScrollViewReader { proxy in
//                        ScrollView(.horizontal,
//                                   showsIndicators: false,
//                                   content: {
//                                       LazyHStack(alignment: .center, spacing: 12, content: {
//                                           ForEach(viewModel.state.items, id: \.id) { item in
//                                               let index = viewModel.state.items.firstIndex(where: {$0.id == item.id})!
//                                               NFTCollectionCard(index: index, item: item, isHorizontal: true, selectedIndex: $selectedIndex)
//                                                   .id(index)
//                                                   .onChange(of: selectedIndex) { value in
//                                                       withAnimation {
//                                                           proxy.scrollTo(value, anchor: .center)
//                                                       }
//                                                   }
//                                           }
//                                       })
//                                       .frame(height: 56)
//                                       .padding(.leading, 18)
//                                       .padding(.bottom, 12)
//
//                                   })
//                    }
//                } else {
//                    LazyVStack(alignment: .center, spacing: 12, content: {
//                        ForEach(viewModel.state.items, id: \.id) { item in
//                            let index = viewModel.state.items.firstIndex(where: {$0.id == item.id})!
//                            NFTCollectionCard(index: index, item: item, isHorizontal: false, selectedIndex: $selectedIndex)
//                        }
//                    })
//                    .padding(.horizontal, 18)
//                }
//            }
//            .background(
//                Color.LL.Neutrals.background
//            )
//        }
//    }
}

// MARK: Preview

struct NFTTabScreen_Previews: PreviewProvider {
    static var previews: some View {
        NFTTabScreen()
    }
}
