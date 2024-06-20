//
//  WalletHomeView.swift
//  FRW
//
//  Created by cat on 2024/3/28.
//

import SwiftUI
import FirebaseAuth
import Flow
import Kingfisher
import SPConfetti
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
    
    private let scrollName: String = "WALLETSCROLL"
    
    var headerHeight: CGFloat {
        size.height * 0.45
    }
    
    var body: some View {
        ZStack {
            NormalView()
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
            ImageAnimated(imageSize: CGSize(width: 60, height: 60), imageNames: ImageAnimated.appRefreshImageNames(), duration: 1.6, isAnimating: state == .loading || state == .primed)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .transition(AnyTransition.move(edge: .top).combined(with: .scale).combined(with: .opacity))
                .visibility(state == .waiting ? .gone : .visible)
                .zIndex(10)
                .offset(y: size.height * 0.45 + 20)
        } content: {
            VStack(spacing: 0) {
                JailbreakTipsView()
                    .visibility(UIDevice.isJailbreak ? .visible : .gone)
                HeaderView()
                WalletInfo()
                ErrorView()
                    .visibility(vm.walletState == .error ? .visible : .gone)
                CoinListView()
                
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
        let height = size.height * 0.45
        GeometryReader { proxy in
            let minY = proxy.frame(in: .named(scrollName)).minY
            let progress = minY / (height * (minY > 0 ? 0.5 : 0.8) + proxy.safeAreaInsets.top - 33)

            HStack {
                Button {
                    vm.sideToggleAction()
                } label: {
                    HStack {
                        Image("icon_wallet_menu")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(Color.Theme.Text.black8)
                            .frame(width: 24, height: 24)
                    }
                    .frame(width: 56, height: 40)
                    .background(Color.Theme.Text.white9.opacity(0.9))
                    .cornerRadius(16)
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
            .padding(.top, safeArea.top )
            .padding([.horizontal, .bottom], 15)
            .background({
                Color.Theme.Text.white9
                    .opacity(-progress)
            })
            .offset(y: -minY)
            
        }
        .frame(height: 40)
    }
    
    @ViewBuilder
    func JailbreakTipsView()-> some View {
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
            Image("wallet_header")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height + (minY > 0 ? minY : 0))
                .clipped()
                .overlay(content: {
                    VisualEffectView(effect: UIBlurEffect(style: .light))
//                    VStack(alignment: .center) {
//                        Spacer()
//                        Text("iOS Version Released")
//                    }
//                    .opacity(1 + (progress > 0 ? -progress : progress))
//                    .offset(y: minY < 0 ? minY : 0)
                })
                .offset(y: -minY)
//                .blur(radius: 10)
                
        }
        .frame(height: headerHeight + safeArea.top)
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
            HStack {
                Text(vm.isHidden ? "****" : "\(CurrencyCache.cache.currencySymbol) \(vm.balance.formatCurrencyString(considerCustomCurrency: true))")
                    .font(.montserrat(size: 30, weight: .bold))
                    .foregroundStyle(Color.Theme.Text.black)
                
                Spacer()
                
                Button {
                    vm.toggleHiddenStatusAction()
                } label: {
                    Image(vm.isHidden ? "icon-wallet-hidden-on" : "icon-wallet-hidden-off")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 16, height: 16)
                }
                .frame(width: 32, height: 32)
                .background(.Theme.Background.grey)
                .cornerRadius(16)
                .clipped()
            }
            
            HStack(spacing: 12) {
                HStack(spacing: 2) {
                    Button {
                        Router.route(to: RouteMap.Wallet.send())
                    } label: {
                        ZStack {
                            Rectangle()
                                .fill(Color.Theme.Accent.grey.opacity(0.08))
                            Image("icon_token_send")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundStyle(Color.Theme.Text.black8)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                            
                        }
                    }
                    .disabled(WalletManager.shared.isSelectedChildAccount)
                    
                    if let swapStatus = RemoteConfigManager.shared.config?.features.swap, swapStatus == true {
                        Button {
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            Router.route(to: RouteMap.Wallet.swap(nil))
                        } label: {
                            ZStack {
                                Rectangle()
                                    .fill(Color.Theme.Accent.grey.opacity(0.08))
                                Image("icon_token_move")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundStyle(Color.Theme.Text.black8)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            }
                        }
                    }
                    
                    Button {
                        Router.route(to: RouteMap.Wallet.receiveQR)
                    } label: {
                        ZStack {
                            Rectangle()
                                .fill(Color.Theme.Accent.grey.opacity(0.08))
                            Image("icon_token_recieve")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundStyle(Color.Theme.Text.black8)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        }
                    }
                    
                    if RemoteConfigManager.shared.config?.features.onRamp ?? false == true && flow.chainID == .mainnet {
                        Button {
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            Router.route(to: RouteMap.Wallet.buyCrypto)
                        } label: {
                            ZStack {
                                Rectangle()
                                    .fill(Color.Theme.Accent.grey.opacity(0.08))
                                Image("icon_token_convert")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundStyle(Color.Theme.Text.black8)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            }
                        }
                    }
                    
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .cornerRadius(20)

                Spacer()
                
                Button  {
                    vm.stakingAction()
                } label: {
                    HStack(spacing: 4) {
                        Image("icon-wallet-coin-add")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(Color.Theme.Text.black8)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            
                        Text("staking".localized)
                            .font(.inter(size: 14, weight: .bold))
                            .foregroundStyle(Color.Theme.Text.black8)
                        
                    }
                    .padding(.horizontal,16)
                    .padding(.vertical, 8)
                    .frame(height: 40)
                    .background(Color.Theme.Accent.grey.opacity(0.08))
                    .cornerRadius(50)
                }
                .disabled(wm.isSelectedChildAccount)
                .visibility(currentNetwork.isMainnet ? .visible : .gone)
                
            }
            .frame(height: 40)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .overlay(alignment: .top, {
            IndicatorBar()
                .offset(y: -12)
        })
        .background(.Theme.Background.white)
    }
    
    @ViewBuilder
    func CoinListView() -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Assets".localized)
                    .font(.inter(size: 18, weight: .bold))
                    .foregroundStyle(Color.Theme.Text.black3)
                Spacer()
                
                Menu {
                    Button {
                        
                    } label: {
                        Image("icon_wallet_asset_hide")
                            .font(.system(size: 20))
                            .foregroundColor(.Theme.Text.black8)
                        Text("Hide 0 Balance".localized)
                            .foregroundColor(.Theme.Text.black8)
                    }
                    
                    Button {
                        
                    } label: {
                        Image("icon_wallet_asset_token")
                            .font(.system(size: 20))
                            .foregroundColor(.Theme.Text.black8)
                        Text("Manage Token".localized)
                            .foregroundColor(.Theme.Text.black8)
                    }
                    
                    Button {
                        
                    } label: {
                        Image("icon_wallet_asset_buy")
                            .font(.system(size: 20))
                            .foregroundColor(.Theme.Text.black8)
                        Text("Buy Token".localized)
                            .foregroundColor(.Theme.Text.black8)
                    }
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color.Theme.Text.black3)
                }

            }
            
            VStack(spacing: 5) {
                ForEach(vm.mCoinItems, id: \.token.symbol) { coin in
                    Button {
                        Router.route(to: RouteMap.Wallet.tokenDetail(coin.token, WalletManager.shared.accessibleManager.isAccessible(coin.token)))
                    } label: {
                        WalletConnectView.CoinCell(coin: coin)
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
extension WalletConnectView {
    
    struct CoinCell: View {
        let coin: WalletViewModel.WalletCoinItemModel
        @EnvironmentObject var vm: WalletViewModel
        @StateObject var stakingManager = StakingManager.shared

        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 18) {
                    KFImage.url(coin.token.iconURL)
                        .placeholder({
                            Image("placeholder")
                                .resizable()
                        })
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
                            HStack() {
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
                            .visibility( WalletManager.shared.accessibleManager.isAccessible(coin.token) ? .visible : .gone)
                            
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
