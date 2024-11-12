//
//  TokenDetailView.swift
//  Flow Wallet
//
//  Created by Selina on 30/6/2022.
//

import Flow
import Kingfisher
import SwiftUI
import SwiftUICharts
import SwiftUIX

// MARK: - TokenDetailView

struct TokenDetailView: RouteableView {
    // MARK: Lifecycle

    init(token: TokenModel, accessible: Bool) {
        _vm = StateObject(wrappedValue: TokenDetailViewModel(token: token))
        self.isAccessible = accessible
    }

    // MARK: Internal

    @Environment(\.colorScheme)
    var colorScheme

    var title: String {
        ""
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                CalloutView(
                    type: .tip,
                    corners: [.topLeading, .topTrailing, .bottomTrailing, .bottomLeading],
                    content: naccessibleDesc()
                )
                .padding(.bottom, 12)
                .visibility(showAccessibleWarning() ? .visible : .gone)

                summaryView
                stakeAdView
                    .visibility(
                        stakingManager.isStaked || !vm.token.isFlowCoin || LocalUserDefaults
                            .shared.stakingGuideDisplayed || WalletManager.shared
                            .isSelectedChildAccount ? .gone : .visible
                    )
                stakeRewardView
                    .visibility(
                        stakingManager.isStaked && vm.token.isFlowCoin && !WalletManager
                            .shared.isSelectedChildAccount ? .visible : .gone
                    )
                activitiesView
                    .visibility(
                        vm.recentTransfers.isEmpty || WalletManager.shared
                            .isSelectedChildAccount ? .gone : .visible
                    )
                chartContainerView.visibility(vm.hasRateAndChartData ? .visible : .gone)
            }
            .padding(.horizontal, 18)
//            .padding(.top, 12)
        }
        .buttonStyle(.plain)
        .backgroundFill(.LL.deepBg)
        .applyRouteable(self)
        .halfSheet(showSheet: $vm.showSheet) {
            if vm.buttonAction == .move {
                MoveTokenView(tokenModel: vm.token, isPresent: $vm.showSheet)
            }
        }
        .navigationBarItems(trailing: HStack(spacing: 6) {
            Menu(systemImage: "ellipsis") {
                Button("Delete EFT", systemImage: "trash") {
                    vm.deleteCustomToken()
                }
            }
            .foregroundStyle(Color.Theme.Background.icon)
            .visibility(vm.showDeleteToken ? .visible : .gone)
        })
    }

    var summaryView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button {
                    if let url = vm.token.website {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    ZStack(alignment: .leading) {
                        HStack(spacing: 5) {
                            Text(vm.token.name)
                                .foregroundColor(.LL.Neutrals.neutrals1)
                                .font(.inter(size: 16, weight: .semibold))
                            Image("icon-right-arrow")
                        }
                        .frame(height: 32)
                        .padding(.trailing, 10)
                        .padding(.leading, 90)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.linearGradient(
                                    colors: colorScheme == .dark ? darkGradientColors :
                                        lightGradientColors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        }

                        KFImage.url(vm.token.iconURL)
                            .placeholder {
                                Image("placeholder")
                                    .resizable()
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                            .padding(.top, -12)
                            .padding(.leading, 18)
                    }
                    .padding(.leading, -18)
                }

                Spacer()

                Button {
                    vm.onMoveToken()
                } label: {
                    HStack {
                        Text("move".localized)
                            .font(.inter(size: 14))
                            .foregroundStyle(Color.Theme.Accent.green)
                        Image("button_move_double")
                            .resizable()
                            .frame(width: 12, height: 12)
                    }
                    .frame(height: 24)
                    .padding(.horizontal, 9)
                    .background(Color.Theme.Accent.green.fixedOpacity())
                    .cornerRadius(8)
                }
                .visibility(vm.movable ? .visible : .gone)
            }

            HStack(alignment: .bottom, spacing: 6) {
                Text(vm.balanceString)
                    .foregroundColor(.LL.Neutrals.neutrals1)
                    .font(.inter(size: 32, weight: .semibold))

                Text(vm.token.symbol?.uppercased() ?? "?")
                    .foregroundColor(
                        colorScheme == .dark ? .LL.Neutrals.neutrals9 : .LL.Neutrals
                            .neutrals8
                    )
                    .font(.inter(size: 14, weight: .medium))
                    .padding(.bottom, 5)
            }
            .padding(.top, 15)

            Text(
                "\(CurrencyCache.cache.currencySymbol)\(vm.balanceAsCurrentCurrencyString) \(CurrencyCache.cache.currentCurrency.rawValue)"
            )
            .foregroundColor(.LL.Neutrals.text)
            .font(.inter(size: 16, weight: .medium))
            .padding(.top, 3)

            HStack(spacing: 2) {
                Button {
                    vm.sendAction()
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.Theme.Accent.green.opacity(0.08))
                        Image("icon_token_send")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                .disabled(WalletManager.shared.isSelectedChildAccount)

                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    Router.route(to: RouteMap.Wallet.swap(nil))
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.Theme.Accent.green.opacity(0.08))
                        Image("icon_token_move")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                .visibility(vm.showSwapButton ? .visible : .gone)

                Button {
                    vm.receiveAction()
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.Theme.Accent.green.opacity(0.08))
                        Image("icon_token_recieve")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }

                Button {
                    Router.route(to: RouteMap.Wallet.buyCrypto)

                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.Theme.Accent.green.opacity(0.08))
                        Image("icon_token_convert")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                .visibility(vm.showBuyButton ? .visible : .gone)
            }
            .frame(height: 40)
            .frame(minWidth: 0, maxWidth: .infinity)
            .cornerRadius(20)
            .padding(.top, 24)
            .padding(.bottom, 14)
            .layoutPriority(100)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 18)
        .background {
            Color.LL.Neutrals.background.cornerRadius(16)
        }
    }

    var activitiesView: some View {
        VStack(spacing: 0) {
            // header
            HStack {
                Text("token_detail_activities".localized)
                    .font(.inter(size: 16, weight: .semibold))
                    .foregroundColor(Color.LL.Neutrals.text)

                Spacer()

                Button {
                    vm.moreTransfersAction()
                } label: {
                    HStack(spacing: 6) {
                        Text("more".localized)
                            .font(.inter(size: 14))
                            .foregroundColor(Color.Flow.accessory)

                        Image("icon-search-arrow")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color.Flow.accessory)
                            .frame(width: 10, height: 10)
                    }
                    .contentShape(Rectangle())
                }
                .frame(height: 50)
            }
            .frame(height: 50)

            // transfer list
            VStack(spacing: 8) {
                ForEach(0..<vm.recentTransfers.count, id: \.self) { index in
                    let transfer = vm.recentTransfers[index]
                    Button {
                        vm.transferDetailAction(transfer)
                    } label: {
                        TransferItemView(model: transfer)
                            .contentShape(Rectangle())
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 8)
        .background {
            Color.LL.Neutrals.background.cornerRadius(16)
        }
    }

    var chartContainerView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("recent_price".localized)
                        .foregroundColor(.LL.Neutrals.text)
                        .font(.inter(size: 16, weight: .semibold))

                    HStack(spacing: 4) {
                        Text(
                            "\(CurrencyCache.cache.currencySymbol)\(vm.rate.formatCurrencyString(considerCustomCurrency: true))"
                        )
                        .foregroundColor(.LL.Neutrals.text)
                        .font(.inter(size: 14, weight: .regular))

                        HStack(spacing: 4) {
                            Image(
                                systemName: vm
                                    .changeIsNegative ? .arrowTriangleDown : .arrowTriangleUp
                            )
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 9, height: 7)
                            .foregroundColor(vm.changeColor)

                            Text(vm.changePercentString)
                                .foregroundColor(vm.changeColor)
                                .font(.inter(size: 12, weight: .semibold))
                        }
                        .padding(.horizontal, 7)
                        .frame(height: 18)
                        .background {
                            vm.changeColor
                                .cornerRadius(4)
                                .opacity(0.12)
                        }

                        Spacer()
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 18)
                }
                sourceSwitchButton
            }
            .padding(.horizontal, 18)

            if colorScheme == .dark {
                Color(hex: "#262626")
                    .opacity(0.64)
                    .frame(height: 1)
            } else {
                Color.LL.Neutrals.neutrals10
                    .opacity(0.64)
                    .frame(height: 1)
            }

            chartRangeView
            chartView
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background {
            Color.LL.Neutrals.background.cornerRadius(16)
        }
    }

    var chartRangeView: some View {
        HStack(spacing: 0) {
            ForEach(ChartRangeType.allCases, id: \.self) { type in
                Button {
                    vm.changeSelectRangeTypeAction(type)
                } label: {
                    SelectButton(title: type.title, isSelect: vm.selectedRangeType == type)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 7)
    }

    // MARK: Private

    @StateObject
    private var vm: TokenDetailViewModel
    @StateObject
    private var stakingManager = StakingManager.shared

    private var isAccessible: Bool = true

    private let lightGradientColors: [Color] = [
        .white.opacity(0),
        Color(hex: "#E6E6E6").opacity(0),
        Color(hex: "#E6E6E6").opacity(1),
    ]
    private let darkGradientColors: [Color] = [
        .white.opacity(0),
        .white.opacity(0),
        Color(hex: "#282828").opacity(1),
    ]
}

// MARK: - Chart

extension TokenDetailView {
    var chartView: some View {
        guard let chartData = vm.chartData else {
            return AnyView(Color.LL.Neutrals.background.frame(height: 163))
        }

        let c =
            FilledLineChart(chartData: chartData)
                .filledTopLine(
                    chartData: chartData,
                    lineColour: ColourStyle(colour: Color.LL.Primary.salmonPrimary),
                    strokeStyle: StrokeStyle(lineWidth: 1, lineCap: .round)
                )
                .touchOverlay(chartData: chartData, specifier: "%.2f")
                .floatingInfoBox(chartData: chartData)
                .yAxisLabels(chartData: chartData, specifier: "%.2f")
                .id(chartData.id)
                .frame(height: 163)
                .padding(.horizontal, 18)
                .padding(.top, 5)

        return AnyView(c)
    }
}

extension TokenDetailView {
    var sourceSwitchButton: some View {
        Menu {
            Button {
                vm.changeMarketAction(.binance)
            } label: {
                HStack {
                    Image("binance")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                    Text("binance".localized)
                        .foregroundColor(.LL.Neutrals.text)
                        .font(.inter(size: 14, weight: .regular))
                }
            }

            Button {
                vm.changeMarketAction(.kraken)
            } label: {
                Image("kraken")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 15, height: 15)
                Text("kraken".localized)
                    .foregroundColor(.LL.Neutrals.text)
                    .font(.inter(size: 14, weight: .regular))
            }

            Button {
                vm.changeMarketAction(.huobi)
            } label: {
                Image("huobi")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 15, height: 15)
                Text("huobi".localized)
                    .foregroundColor(.LL.Neutrals.text)
                    .font(.inter(size: 14, weight: .regular))
            }
        } label: {
            VStack(alignment: .trailing, spacing: 14) {
                HStack(spacing: 6) {
                    Image(systemName: String.arrowDown)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                        .foregroundColor(.LL.Neutrals.neutrals9)

                    Text("data_from".localized)
                        .foregroundColor(.LL.Neutrals.neutrals9)
                        .font(.inter(size: 14, weight: .regular))
                }

                HStack(spacing: 6) {
                    Image(vm.market.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                        .foregroundColor(.LL.Neutrals.neutrals9)

                    Text(vm.market.rawValue.capitalized)
                        .foregroundColor(.LL.Neutrals.neutrals9)
                        .font(.inter(size: 14, weight: .regular))
                }
            }
        }
    }
}

extension TokenDetailView {
    struct SelectButton: View {
        // MARK: Internal

        @Environment(\.colorScheme)
        var colorScheme
        let title: String
        let isSelect: Bool

        var body: some View {
            Text(title)
                .foregroundColor(labelColor)
                .font(labelFont)
                .frame(height: 26)
                .padding(.horizontal, 7)
                .background {
                    labelBgColor
                        .cornerRadius(8)
                        .visibility(isSelect ? .visible : .invisible)
                }
        }

        // MARK: Private

        private var labelBgColor: Color {
            colorScheme == .dark ? Color.LL.Neutrals.neutrals10 : Color.LL.Neutrals.outline
        }

        private var labelColor: Color {
            if colorScheme == .dark {
                return isSelect ? Color.LL.Neutrals.text : Color.LL.Neutrals.note
            } else {
                return isSelect ? Color.LL.Neutrals.text : Color.LL.Neutrals.note
            }
        }

        private var labelFont: Font {
            isSelect ? .inter(size: 12, weight: .semibold) : .inter(size: 12, weight: .regular)
        }
    }

    struct TransferItemView: View {
        let model: FlowScanTransfer

        var body: some View {
            HStack(spacing: 8) {
                KFImage.url(URL(string: model.image ?? ""))
                    .placeholder {
                        Image("placeholder")
                            .resizable()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 5) {
                        Image(
                            systemName: model
                                .transferType == .send ? "arrow.up.right" : "arrow.down.left"
                        )
                        .resizable()
                        .foregroundColor(Color.LL.Neutrals.text)
                        .frame(width: 12, height: 12)
                        .aspectRatio(contentMode: .fit)

                        Text(model.title ?? "")
                            .font(.inter(size: 14, weight: .semibold))
                            .foregroundColor(Color.LL.Neutrals.text)
                            .lineLimit(1)
                    }

                    Text(model.transferDesc)
                        .font(.inter(size: 12))
                        .foregroundColor(Color.LL.Neutrals.text3)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .trailing, spacing: 5) {
                    Text(model.amountString)
                        .font(.inter(size: 14))
                        .foregroundColor(Color.LL.Neutrals.text)
                        .lineLimit(1)
                        .visibility(model.amountString == "-" ? .gone : .visible)

                    Text(model.statusText)
                        .font(.inter(size: 12))
                        .foregroundColor(model.swiftUIStatusColor)
                        .lineLimit(1)
                }
                .frame(alignment: .trailing)
            }
            .frame(height: 50)
        }
    }
}

// MARK: - Stake

extension TokenDetailView {
    var stakeRewardView: some View {
        Button {
            vm.stakeDetailAction()
        } label: {
            VStack(spacing: 0) {
                // header
                HStack {
                    Text("stake_reward_title".localized)
                        .font(.inter(size: 16, weight: .semibold))
                        .foregroundColor(Color.LL.Neutrals.text)

                    Spacer()

                    HStack(spacing: 10) {
                        Text(
                            "\(stakingManager.stakingCount.formatCurrencyString(digits: 3)) \(vm.token.symbol?.uppercased() ?? "?")"
                        )
                        .font(.inter(size: 14))
                        .foregroundColor(Color.LL.Neutrals.text)

                        Image("icon-account-arrow-right")
                            .renderingMode(.template)
                            .foregroundColor(.Flow.accessory)
                    }
                    .contentShape(Rectangle())
                    .frame(height: 50)
                }
                .frame(height: 50)

                // reward summary
                HStack(spacing: 12) {
                    // daily
                    VStack(alignment: .leading, spacing: 13) {
                        Text("stake_daily_reward".localized)
                            .font(.inter(size: 14, weight: .bold))
                            .foregroundColor(Color.LL.Neutrals.text)

                        Text(
                            "\(CurrencyCache.cache.currentCurrency.symbol)\(stakingManager.dayRewardsASUSD.formatCurrencyString(digits: 3, considerCustomCurrency: true))"
                        )
                        .font(.inter(size: 24, weight: .bold))
                        .foregroundColor(Color.LL.Neutrals.text)

                        Text(
                            "\(stakingManager.dayRewards.formatCurrencyString(digits: 3)) \(vm.token.symbol?.uppercased() ?? "?")"
                        )
                        .font(.inter(size: 12, weight: .semibold))
                        .foregroundColor(Color.LL.Neutrals.text3)
                    }
                    .padding(.all, 13)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .background(Color.LL.deepBg)
                    .cornerRadius(16)

                    // mothly
                    VStack(alignment: .leading, spacing: 13) {
                        Text("stake_mothly_reward".localized)
                            .font(.inter(size: 14, weight: .bold))
                            .foregroundColor(Color.LL.Neutrals.text)

                        Text(
                            "\(CurrencyCache.cache.currentCurrency.symbol)\(stakingManager.monthRewardsASUSD.formatCurrencyString(digits: 3, considerCustomCurrency: true))"
                        )
                        .font(.inter(size: 24, weight: .bold))
                        .foregroundColor(Color.LL.Neutrals.text)

                        Text(
                            "\(stakingManager.monthRewards.formatCurrencyString(digits: 3)) \(vm.token.symbol?.uppercased() ?? "?")"
                        )
                        .font(.inter(size: 12, weight: .semibold))
                        .foregroundColor(Color.LL.Neutrals.text3)
                    }
                    .padding(.all, 13)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .background(Color.LL.deepBg)
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 14)
            .background {
                Color.LL.Neutrals.background.cornerRadius(16)
            }
        }
    }

    var stakeAdView: some View {
        Button {
            if !LocalUserDefaults.shared.stakingGuideDisplayed {
                Router.route(to: RouteMap.Wallet.stakeGuide)
                return
            }

            Router.route(to: RouteMap.Wallet.stakingSelectProvider)
        } label: {
            ZStack(alignment: .topLeading) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 0) {
                            Text("stake_ad_title_1".localized(vm.token.symbol?.uppercased() ?? "?"))
                                .font(.inter(size: 16, weight: .bold))
                                .foregroundColor(Color.LL.Neutrals.text)

                            Text("stake_ad_title_2".localized)
                                .font(.inter(size: 16, weight: .bold))
                                .foregroundColor(Color.clear)
                                .background {
                                    Rectangle()
                                        .fill(.linearGradient(
                                            colors: [Color(hex: "#FFC062"), Color(hex: "#0BD3FF")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                        .mask {
                                            Text("stake_ad_title_2".localized)
                                                .font(.inter(size: 16, weight: .bold))
                                                .foregroundColor(Color.black)
                                        }
                                }

                            Spacer()
                        }

                        Text("stake_ad_desc".localized)
                            .font(.inter(size: 14, weight: .medium))
                            .foregroundColor(
                                colorScheme == .dark ? .LL.Neutrals.neutrals9 : .LL
                                    .Neutrals.neutrals8
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image("icon-stake-ad-arrow")
                        .renderingMode(.template)
                        .foregroundStyle(Color.Flow.accessory)
                }
                .frame(maxHeight: .infinity)

                Image("icon-stake-ad-crown")
                    .padding(.top, -10)
                    .padding(.leading, -10)
            }
            .padding(.horizontal, 18)
            .frame(height: 72, alignment: .topLeading)
            .background {
                Color.LL.Neutrals.background.cornerRadius(16)
            }
        }
    }
}

// MARK: - Data for UI

extension TokenDetailView {
    func naccessibleDesc() -> String {
        let token = vm.token.name
        let account = WalletManager.shared.selectedAccountWalletName
        let desc = "accessible_not_x_x".localized(token, account)
        return desc
    }

    func showAccessibleWarning() -> Bool {
        !isAccessible
    }
}
