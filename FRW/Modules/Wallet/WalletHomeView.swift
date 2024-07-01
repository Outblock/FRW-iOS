//
//  WalletHomeView.swift
//  FRW
//
//  Created by cat on 2024/3/28.
//

import FirebaseAuth
import Flow
import Kingfisher
import SPConfetti
import SwiftUI
import SwiftUIPager
import SwiftUIX

extension WalletHomeView: AppTabBarPageProtocol {
    static func tabTag() -> AppTabType {
        return .wallet
    }

    static func iconName() -> String {
        "CoinHover"
    }

    static func color() -> Color {
        return .Flow.accessory
    }
}

struct WalletHomeView: View {
    var body: some View {
        GeometryReader {
            let safeArea = $0.safeAreaInsets
            let size = $0.size
            WalletContentView(safeArea: safeArea, size: size)
                .ignoresSafeArea(.container, edges: .top)
        }
    }
}

struct WalletContentView: View {
    var safeArea: EdgeInsets
    var size: CGSize
    
    @StateObject var um = UserManager.shared
    @StateObject var wm = WalletManager.shared
    @StateObject private var vm = WalletViewModel()
    @State var isRefreshing: Bool = false
    @State private var showActionSheet = false
    @AppStorage("WalletCardBackrgound")
    private var walletCardBackrgound: String = "fade:0"
    
    
    private let scrollName: String = "WALLETSCROLL"
    
    var headerHeight: CGFloat {
        size.height * 0.3
    }
    
    var body: some View {
        ZStack {
            GuestView().visibility(um.isLoggedIn ? .gone : .visible)
            NormalView().visibility(um.isLoggedIn ? .visible : .gone)
        }
        .halfSheet(showSheet: $vm.backupTipsPresent) {
            BackupTipsView(closeAction: {
                vm.backupTipsPresent = false
            })
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    func NormalView() -> some View {
        RefreshableScrollView(showsIndicators: false, loadingViewBackgroundColor: .clear) { done in
            if isRefreshing {
                return
            }
            isRefreshing = true
            vm.reloadWalletData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                done()
                isRefreshing = false
            }
        } progress: { state in
            ImageAnimated(imageSize: CGSize(width: 60, height: 60),
                          imageNames: ImageAnimated.appRefreshImageNames(),
                          duration: 1.6,
                          isAnimating: state == .loading || state == .primed)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .transition(
                    AnyTransition.move(edge: .bottom).combined(with: .scale).combined(with: .opacity)
                )
                .visibility(state == .waiting ? .gone : .visible)
                .zIndex(2)
                .offset(y: headerHeight + 20)
        } content: {
            VStack(spacing: 0) {
                JailbreakTipsView()
                    .visibility(UIDevice.isJailbreak ? .visible : .gone)
                HeaderView()
                    .zIndex(1)
                WalletInfo()
                    .zIndex(10)
                ErrorView()
                    .visibility(vm.walletState == .error ? .visible : .gone)
                    .zIndex(11)
                CoinListView()
                    .zIndex(20)
            }
            .overlay(alignment: .top) {
                TopMenuView()
            }
        }
        .coordinateSpace(name: scrollName)
        
        .environmentObject(vm)
        .mockPlaceholder(vm.needShowPlaceholder)
    }
    
    @ViewBuilder
    func TopMenuView() -> some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .named(scrollName)).minY
            let progress = minY / (headerHeight * (minY > 0 ? 0.5 : 0.8) + proxy.safeAreaInsets.top - 33)

            HStack {
                Button {
                    vm.sideToggleAction()
                } label: {
                    HStack {
                        wm.currentAccount.emoji.icon(size: 24)
                    }
                    .frame(width: 40, height: 40)
                    .background(Color.Theme.Text.white9.opacity(0.9))
                    .cornerRadius(20)
                }
                
                Spacer()
                
                HStack {
                    Button {
                        vm.moveAssetsAction()
                    } label: {
                        Image("icon_wallet_home_move")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color.Theme.Text.black8)
                            .frame(width: 24, height: 24)
                            .padding(8)
                    }
                    .visibility(EVMAccountManager.shared.openEVM ? .visible : .gone)
                    
                    Button {
                        Router.route(to: RouteMap.Wallet.transactionList(nil))
                    } label: {
                        Image("icon_wallet_home_time")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color.Theme.Text.black8)
                            .frame(width: 24, height: 24)
                            .padding(8)
                    }
                    
                    Button {
                        vm.scanAction()
                    } label: {
                        Image("icon-wallet-scan")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(Color.Theme.Text.black8)
                            .frame(width: 24, height: 24)
                            .padding(8)
                    }
                }
                .padding(.horizontal, 8)
                .background(Color.Theme.Text.white9.opacity(0.9))
                .cornerRadius(16)
            }
            .padding(.top, safeArea.top)
            .padding([.horizontal, .bottom], 15)
            .background {
                Color.Theme.Text.white9
                    .opacity(-progress)
            }
            .offset(y: -minY)
        }
        .frame(height: 40)
    }
    
    @ViewBuilder
    func JailbreakTipsView() -> some View {
        Button {
            Router.route(to: RouteMap.Wallet.jailbreakAlert)
        } label: {
            HStack(spacing: 8) {
                Image("icon-warning-mark")
                    .renderingMode(.template)
                    .foregroundColor(Color.LL.Warning.warning2)
                
                Text("jailbreak_alert_msg".localized)
                    .font(.inter(size: 16, weight: .medium))
                    .foregroundColor(Color.LL.Warning.warning2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                
                Image("icon-account-arrow-right")
                    .renderingMode(.template)
                    .foregroundColor(Color.LL.Warning.warning2)
            }
            .padding(.all, 18)
            .background(Color.LL.Warning.warning5)
            .cornerRadius(16)
            .padding(.horizontal, 18)
        }
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        GeometryReader { proxy in
            let size = proxy.size
            let minY = proxy.frame(in: .named(scrollName)).minY
            let progress = minY / (headerHeight * (minY > 0 ? 0.5 : 0.8))
            ZStack(alignment: .bottom) {
                HStack {
                    if WalletManager.shared.isSelectedChildAccount {
                        childAccountBackground
                    } else {
                        CardBackground(value: walletCardBackrgound).renderView()
                    }
                }
                .overlay {
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: .white.opacity(0), location: 0.00),
                            Gradient.Stop(color: .black.opacity(0.3), location: 1.00),
                        ],
                        startPoint: UnitPoint(x: 0.5, y: 0),
                        endPoint: UnitPoint(x: 0.5, y: 1)
                    )
                    .visibility(vm.showHeaderMask ? .visible : .gone)
                    
                }
                .onLongPressGesture {
                    if showActionSheet {
                        return
                    }
                    self.showActionSheet = true
                }
                
                VStack(alignment: .trailing) {
                    Spacer()
                    if vm.notiList.count > 1 {
                        HStack {
                            HStack(spacing: 15) {
                                ForEach(vm.notiList.indices, id: \.self) { index in
                                    Capsule()
                                        .fill(vm.currentPage == index ? Color.Theme.Accent.green : Color.Theme.Line.line)
                                        .frame(width: vm.currentPage == index ? 20 : 7, height: 7)
                                }
                            }
                            .overlay(alignment: .leading) {
                                Capsule()
                                    .fill(Color.Theme.Accent.green)
                                    .frame(width: 20, height: 7)
                                    .offset(x: CGFloat(22 * vm.currentPage))
                            }
                        }
                    }
                    
                    Pager(page: vm.page, data: 0 ..< vm.notiList.count, id: \.self) { index in
                        let item = vm.notiList[index]
                        WalletNotificationView(data: item) {} onAction: {}
                    }
                    .itemSpacing(10)
                    .onPageWillChange { willIndex in
                        vm.onPageIndexChangeAction(willIndex)
                    }
                    .frame(height: 72)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 16)
                .clipped()
            }
            .frame(width: size.width, height: size.height + (minY > 0 ? minY : 0))
            .clipped()
            .overlay {
                Color.Theme.Text.white9
                    .opacity(-progress)
            }
            .offset(y: -minY)
            .confirmationDialog("Select a color", isPresented: $showActionSheet, titleVisibility: .hidden) {
                Button("change wallpaper") {
                    showWallpaper()
                }
            }
        }
        .frame(height: headerHeight + safeArea.top)
    }
    
    private func showWallpaper() {
        Router.route(to: RouteMap.Profile.wallpaper)
    }
    
    private var childAccountBackground: some View {
        ZStack {
            KFImage.url(URL(string: WalletManager.shared.selectedAccountIcon))
                .placeholder {
                    Image("placeholder")
                        .resizable()
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .blur(radius: 6)
            
            LinearGradient(colors:
                [
                    Color(hex: "#333333"),
                    Color(hex: "#333333"),
                    Color(hex: "#333333").opacity(0.88),
                    Color(hex: "#333333").opacity(0.32),
                ],
                startPoint: .leading,
                endPoint: .trailing)
        }
    }
    
    @ViewBuilder
    func IndicatorBar() -> some View {
        HStack {
            Spacer()
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 71, height: 5)
                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                .cornerRadius(8)
            Spacer()
        }
    }
    
    @ViewBuilder
    func WalletInfo() -> some View {
        VStack {
            HStack(spacing: 16) {
                Text(vm.isHidden ? "****" : "\(CurrencyCache.cache.currencySymbol) \(vm.balance.formatCurrencyString(considerCustomCurrency: true))")
                    .font(.montserrat(size: 30, weight: .bold))
                    .foregroundStyle(Color.Theme.Text.black)
                
                Button {
                    vm.toggleHiddenStatusAction()
                } label: {
                    Image(vm.isHidden ? "icon-wallet-hidden-on" : "icon-wallet-hidden-off")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(Color.Theme.Text.black3)
                        .frame(width: 12, height: 12)
                }
                .frame(width: 32, height: 32)
                .background(.Theme.Background.grey)
                .cornerRadius(16)
                .clipped()
                
                Spacer()
                
                Button {
                    vm.copyAddressAction()
                } label: {
                    HStack {
                        Image("icon-address-copy")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color.Theme.Text.black3)
                            .frame(width: 16, height: 16)
                    }
                    .frame(width: 32, height: 32)
                    .background(Color.Theme.Background.grey)
                    .cornerRadius(16)
                }
            }
            
            walletActionBar()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .overlay(alignment: .top) {
            IndicatorBar()
                .offset(y: -12)
        }
        .background(.Theme.Background.white)
    }
    
    private func walletActionBar() -> some View {
        let showSwap = (RemoteConfigManager.shared.config?.features.swap ?? false) == true
        let showStake = currentNetwork.isMainnet
        let isH = (showSwap == false && showStake == false)
        
        return HStack {
            WalletHomeView.ActionView(isH: isH, action: .send)
                .disabled(WalletManager.shared.isSelectedChildAccount)
            WalletHomeView.ActionView(isH: isH, action: .receive)
            WalletHomeView.ActionView(isH: isH, action: .swap)
                .visibility(showSwap ? .visible : .gone)
            WalletHomeView.ActionView(isH: isH, action: .stake)
                .visibility(showStake ? .visible : .gone)
                .disabled(wm.isSelectedChildAccount)
        }
    }
    
    @ViewBuilder
    func CoinListView() -> some View {
        VStack(spacing: 16) {
            HStack {
                Text((vm.mCoinItems.count > 0 ? "\(vm.mCoinItems.count) " : "") + "tokens".localized)
                    .font(.inter(size: 18, weight: .bold))
                    .foregroundStyle(Color.Theme.Text.black3)
                Spacer()
                
                if RemoteConfigManager.shared.config?.features.onRamp ?? false == true && flow.chainID == .mainnet {
                    Button {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        Router.route(to: RouteMap.Wallet.buyCrypto)
                    } label: {
                        HStack(spacing: 4) {
                            Image("icon_wallet_action_buy")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color.Theme.Text.black3)
                                .background(.clear)
                                .frame(width: 24, height: 24)
                            
                            Text("buy_uppercase".localized)
                                .font(.inter(size: 14, weight: .semibold))
                                .foregroundColor(Color.Theme.Text.black3)
                        }
                        .padding(.horizontal, 8)
                        .background(Color.Theme.Background.grey)
                        .cornerRadius(12)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                
                Button {
                    Router.route(to: RouteMap.Wallet.addToken)
                } label: {
                    Image("icon-wallet-coin-add")
                        .renderingMode(.template)
                        .foregroundColor(Color.Theme.Text.black3)
                        .frame(width: 24, height: 24)
                }
                .disabled(wm.isSelectedChildAccount)
                .buttonStyle(ScaleButtonStyle())
            }
            
            VStack(spacing: 5) {
                ForEach(vm.mCoinItems, id: \.token.symbol) { coin in
                    Button {
                        Router.route(to: RouteMap.Wallet.tokenDetail(coin.token, WalletManager.shared.accessibleManager.isAccessible(coin.token)))
                    } label: {
                        WalletHomeView.CoinCell(coin: coin)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            
            Spacer(minLength: headerHeight + safeArea.top)
        }
        .padding(.horizontal, 16)
        .background(.Theme.Background.white)
    }
    
    @ViewBuilder
    func ErrorView() -> some View {
        Text("error")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundFill(.LL.Neutrals.background)
    }
    
    @ViewBuilder
    func GuestView() -> some View {
        EmptyWalletView()
    }
}

private let CoinIconHeight: CGFloat = 43
private let CoinCellHeight: CGFloat = 72
extension WalletHomeView {
    struct CoinCell: View {
        let coin: WalletViewModel.WalletCoinItemModel
        @EnvironmentObject var vm: WalletViewModel
        @StateObject var stakingManager = StakingManager.shared

        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 18) {
                    KFImage.url(coin.token.iconURL)
                        .placeholder {
                            Image("placeholder")
                                .resizable()
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: CoinIconHeight, height: CoinIconHeight)
                        .clipShape(Circle())

                    VStack(spacing: 7) {
                        HStack {
                            Text(coin.token.name)
                                .foregroundColor(.LL.Neutrals.text)
                                .font(.inter(size: 14, weight: .bold))

                            Spacer()

                            Text("\(vm.isHidden ? "****" : coin.balance.formatCurrencyString()) \(coin.token.symbol?.uppercased() ?? "?")")
                                .foregroundColor(.LL.Neutrals.text)
                                .font(.inter(size: 14, weight: .medium))
                        }

                        HStack {
                            HStack {
                                Text(coin.priceValue)
                                    .foregroundColor(.LL.Neutrals.neutrals7)
                                    .font(.inter(size: 14, weight: .regular))

                                Text(coin.changeString)
                                    .foregroundColor(coin.changeColor)
                                    .font(.inter(size: 12, weight: .semibold))
                                    .frame(height: 22)
                                    .padding(.horizontal, 6)
                                    .background(coin.changeBG)
                                    .cornerRadius(11, style: .continuous)
                            }
                            .visibility(WalletManager.shared.accessibleManager.isAccessible(coin.token) ? .visible : .gone)
                            
                            Text("Inaccessible")
                                .foregroundStyle(Color.Flow.Font.inaccessible)
                                .font(Font.inter(size: 10, weight: .semibold))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 5)
                                .background(.Flow.Font.inaccessible.opacity(0.16))
                                .cornerRadius(4, style: .continuous)
                                .visibility(WalletManager.shared.accessibleManager.isAccessible(coin.token) ? .gone : .visible)

                            Spacer()

                            Text(vm.isHidden ? "****" : "\(CurrencyCache.cache.currencySymbol)\(coin.balanceAsCurrentCurrency)")
                                .foregroundColor(.LL.Neutrals.neutrals7)
                                .font(.inter(size: 14, weight: .regular))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(minHeight: CoinCellHeight)
                
                HStack(spacing: 0) {
                    Divider()
                        .frame(width: 1, height: 10)
                        .foregroundColor(Color.LL.Neutrals.neutrals4)
                    
                    Spacer()
                }
                .padding(.leading, 24)
                .offset(y: -5)
                .visibility(coin.token.isFlowCoin && stakingManager.isStaked ? .visible : .gone)
                
                Button {
                    StakingManager.shared.goStakingAction()
                } label: {
                    HStack(spacing: 0) {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(Color.LL.Neutrals.neutrals4)
                        
                        Text("staked_flow".localized)
                            .foregroundColor(.LL.Neutrals.text)
                            .font(.inter(size: 14, weight: .semibold))
                            .padding(.leading, 31)
                        
                        Spacer()
                        
                        Text("\(vm.isHidden ? "****" : stakingManager.stakingCount.formatCurrencyString()) FLOW")
                            .foregroundColor(.LL.Neutrals.text)
                            .font(.inter(size: 14, weight: .medium))
                    }
                }
                .padding(.leading, 19)
                .visibility(coin.token.isFlowCoin && stakingManager.isStaked ? .visible : .gone)
            }
        }
    }
}

// MARK: ActionView

extension WalletHomeView {
    enum Action: String {
        case send, receive, swap, stake
        
        var icon: String {
            switch self {
            case .send:
                return "icon_token_send"
            case .receive:
                return "icon_token_recieve"
            case .swap:
                return "wallet-swap-stroke"
            case .stake:
                return "icon_wallet_action_stake"
            }
        }
        
        func doEvent() {
            switch self {
            case .send:
                Router.route(to: RouteMap.Wallet.send())
            case .receive:
                Router.route(to: RouteMap.Wallet.receiveQR)
            case .swap:
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                Router.route(to: RouteMap.Wallet.swap(nil))
            case .stake:
                if !LocalUserDefaults.shared.stakingGuideDisplayed && !StakingManager.shared.isStaked {
                    Router.route(to: RouteMap.Wallet.stakeGuide)
                    return
                }
                
                Router.route(to: RouteMap.Wallet.stakingList)
            }
        }
    }

    struct ActionView: View {
        let isH: Bool
        let action: WalletHomeView.Action
        var body: some View {
            Button {
                action.doEvent()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                container {
                    Image(action.icon)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(Color.Theme.Text.black8)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    
                    Text(action.rawValue.capitalized)
                        .font(.inter(size: 12, weight: .semibold))
                        .foregroundStyle(Color.Theme.Text.black8)
                }
            }
            .buttonStyle(ScaleButtonStyle())
        }
        
        public func container<Content: View>(@ViewBuilder content: () -> Content) -> some View {
            return HStack(alignment: .center, spacing: 10) {
                if isH {
                    HStack {
                        content()
                    }
                } else {
                    VStack {
                        content()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .frame(alignment: .center)
            .background(Color.Theme.Background.grey)
            .cornerRadius(16)
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

#Preview {
    Group {
        WalletHomeView()
            .preferredColorScheme(.dark)
    }
}
