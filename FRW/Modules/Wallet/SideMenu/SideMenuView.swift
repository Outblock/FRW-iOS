//
//  SideMenuView.swift
//  Flow Wallet
//
//  Created by Selina on 4/1/2023.
//

import Combine
import Kingfisher
import SwiftUI

private let SideOffset: CGFloat = 65

extension SideMenuViewModel {
    struct AccountPlaceholder {
        let uid: String
        let avatar: String
    }
}

class SideMenuViewModel: ObservableObject {
    @Published var nftCount: Int = 0
    @Published var accountPlaceholders: [AccountPlaceholder] = []
    @Published var isSwitchOpen = false
    @Published var userInfoBackgroudColor = Color.LL.Neutrals.neutrals6
    @Published var walletBalance: [String: String] = [:]

    var colorsMap: [String: Color] = [:]

    private var cancelSets = Set<AnyCancellable>()
    var currentAddress: String {
        WalletManager.shared.getWatchAddressOrChildAccountAddressOrPrimaryAddress() ?? ""
    }

    init() {
        UserManager.shared.$loginUIDList
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink { [weak self] uidList in
                guard let self = self else { return }

                self.accountPlaceholders = Array(uidList.dropFirst().prefix(2)).map { uid in
                    let avatar = MultiAccountStorage.shared.getUserInfo(uid)?.avatar.convertedAvatarString() ?? ""
                    return AccountPlaceholder(uid: uid, avatar: avatar)
                }
            }.store(in: &cancelSets)

        WalletManager.shared.balanceProvider.$balances
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink { [weak self] balances in
                self?.walletBalance = balances
            }.store(in: &cancelSets)
        NotificationCenter.default.addObserver(self, selector: #selector(onToggle), name: .toggleSideMenu, object: nil)
    }

    @objc func onToggle() {
        isSwitchOpen = false
    }

    func scanAction() {
        NotificationCenter.default.post(name: .toggleSideMenu)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            ScanHandler.scan()
        }
    }

    func pickColor(from url: String) {
        guard !url.isEmpty else {
            userInfoBackgroudColor = Color.LL.Neutrals.neutrals6
            return
        }
        if let color = colorsMap[url] {
            userInfoBackgroudColor = color
            return
        }
        Task {
            let color = await ImageHelper.mostFrequentColor(from: url)
            DispatchQueue.main.async {
                self.colorsMap[url] = color
                self.userInfoBackgroudColor = color
            }
        }
    }

    func switchAccountAction(_ uid: String) {
        Task {
            do {
                HUD.loading()
                try await UserManager.shared.switchAccount(withUID: uid)
                HUD.dismissLoading()
            } catch {
                log.error("switch account failed", context: error)
                HUD.dismissLoading()
                HUD.error(title: error.localizedDescription)
            }
        }
    }

    func switchAccountMoreAction() {
        Router.route(to: RouteMap.Profile.switchProfile)
    }

    func onClickEnableEVM() {
        NotificationCenter.default.post(name: .toggleSideMenu)
        Router.route(to: RouteMap.Wallet.enableEVM)
    }

    func balanceValue(at address: String) -> String {
        guard let value = WalletManager.shared.balanceProvider.balanceValue(at: address) else {
            return ""
        }
        return "\(value) FLOW"
    }

    func switchProfile() {
        LocalUserDefaults.shared.recentToken = nil
    }
}

struct SideMenuView: View {
    @StateObject private var vm = SideMenuViewModel()
    @StateObject private var um = UserManager.shared
    @StateObject private var wm = WalletManager.shared
    @StateObject private var cm = ChildAccountManager.shared
    @StateObject private var evmManager = EVMAccountManager.shared
    @AppStorage("isDeveloperMode") private var isDeveloperMode = false
    @State private var showSwitchUserAlert = false

    private let cPadding = 12.0

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                VStack {
                    cardView
                        .padding(.top, proxy.safeAreaInsets.top)

                    ScrollView {
                        VStack {
                            enableEVMView
                                .padding(.top, 24)
                                .visibility(evmManager.showEVM ? .visible : .gone)

                            addressListView
                        }
                    }

                    bottomMenu
                        .padding(.bottom, 16 + proxy.safeAreaInsets.bottom)
                }
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.Theme.Background.white)
                .ignoresSafeArea()

                // placeholder, do not use this
                VStack {}
                    .frame(width: SideOffset)
                    .frame(maxHeight: .infinity)
            }
        }
    }

    var cardView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                KFImage.url(URL(string: um.userInfo?.avatar.convertedAvatarString() ?? ""))
                    .placeholder {
                        Image("placeholder")
                            .resizable()
                    }
                    .onSuccess { _ in
                        vm.pickColor(from: um.userInfo?.avatar.convertedAvatarString() ?? "")
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .cornerRadius(24)

                Spacer()

                Button {
                    vm.switchAccountMoreAction()
                } label: {
                    Image("icon-more")
                        .renderingMode(.template)
                        .foregroundColor(Color.LL.Neutrals.text)
                }
            }

            Text(um.userInfo?.nickname ?? "lilico".localized)
                .foregroundColor(.LL.Neutrals.text)
                .font(.inter(size: 20, weight: .bold))
                .frame(height: 32)
                .padding(.top, 4)
                .padding(.bottom, 24)
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            LinearGradient(
                stops: [
                    Gradient.Stop(color: vm.userInfoBackgroudColor.opacity(00), location: 0.00),
                    Gradient.Stop(color: vm.userInfoBackgroudColor.opacity(0.64), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1)
            )
            .cornerRadius(12)
        }
    }

    var enableEVMView: some View {
        return VStack {
            ZStack(alignment: .topLeading) {
                Image("icon_planet")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .zIndex(1)
                    .offset(x: 8, y: -8)
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Text("enable_path".localized)
                            .font(.inter(size: 16, weight: .semibold))
                            .foregroundStyle(Color.Theme.Text.black8)
                        Text("evm_on_flow".localized)
                            .font(.inter(size: 16, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.Theme.Accent.blue, Color.Theme.Accent.green],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text(" !")
                            .font(.inter(size: 16, weight: .semibold))
                            .foregroundStyle(Color.Theme.Text.black8)
                        Spacer()
                        Image("right-arrow-stroke")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .frame(height: 24)
                    Text("enable_evm_tip".localized)
                        .font(.inter(size: 14))
                        .foregroundStyle(Color.Theme.Text.black3)
                        .frame(height: 24)
                }
                .frame(height: 72)
                .padding(.horizontal, 18)
                .background(.Theme.Background.white)
                .cornerRadius(16)
                .shadow(color: Color.Theme.Background.white.opacity(0.08), radius: 16, y: 4)
                .offset(y: 8)
            }
        }
        .onTapGesture {
            vm.onClickEnableEVM()
        }
    }

    var addressListView: some View {
        VStack(spacing: 0) {
            Section {
                VStack(spacing: 0) {
                    AccountSideCell(address: WalletManager.shared.getPrimaryWalletAddress() ?? "",
                                    currentAddress: vm.currentAddress,
                                    detail: vm.balanceValue(at: WalletManager.shared.getPrimaryWalletAddress() ?? "")) { _, action in
                        if action == .card {
                            vm.switchProfile()
                            WalletManager.shared.changeNetwork(LocalUserDefaults.shared.flowNetwork)
                        }
                    }
                }
                .cornerRadius(12)
                .animation(.easeInOut, value: WalletManager.shared.getPrimaryWalletAddress())
            } header: {
                HStack {
                    Text("main_account".localized)
                        .font(.inter(size: 12))
                        .foregroundStyle(Color.Theme.Text.black3)
                        .padding(.vertical, 8)
                    Spacer()
                }
            }

            Color.clear
                .frame(height: 16)

            Section {
                VStack(spacing: 0) {
                    ForEach(evmManager.accounts, id: \.address) { account in
                        let address = account.showAddress
                        AccountSideCell(address: address,
                                        currentAddress: vm.currentAddress,
                                        detail: vm.balanceValue(at: address)) { _, action in
                            if action == .card {
                                vm.switchProfile()
                                ChildAccountManager.shared.select(nil)
                                EVMAccountManager.shared.select(account)
                            }
                        }
                    }

                    ForEach(cm.childAccounts, id: \.addr) { childAccount in
                        if let address = childAccount.addr {
                            AccountSideCell(address: address,
                                            currentAddress: vm.currentAddress,
                                            name: childAccount.aName,
                                            logo: childAccount.icon) { _, action in
                                if action == .card {
                                    vm.switchProfile()
                                    EVMAccountManager.shared.select(nil)
                                    ChildAccountManager.shared.select(childAccount)
                                }
                            }
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Linked_Account::message".localized)
                        .font(.inter(size: 12))
                        .foregroundStyle(Color.Theme.Text.black3)
                        .padding(.vertical, 8)
                    Spacer()
                }
                .visibility(evmManager.accounts.count > 0 || cm.childAccounts.count > 0 ? .visible : .gone)
            }
        }
    }

    var bottomMenu: some View {
        VStack {
            Divider()
                .background(.Theme.Line.line)
                .frame(height: 1)
                .padding(.bottom, 24)
            if isDeveloperMode {
                HStack {
                    Image("icon_side_link")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.Theme.Text.black8)
                    Text("Network::message".localized)
                        .lineLimit(1)
                        .font(.inter(size: 14, weight: .semibold))
                        .foregroundStyle(Color.Theme.Text.black8)

                    Spacer()

                    Menu {
                        VStack {
                            Button {
                                NotificationCenter.default.post(name: .toggleSideMenu)
                                WalletManager.shared.changeNetwork(.mainnet)

                            } label: {
                                NetworkMenuItem(network: .mainnet, currentNetwork: LocalUserDefaults.shared.flowNetwork)
                            }

                            Button {
                                NotificationCenter.default.post(name: .toggleSideMenu)
                                WalletManager.shared.changeNetwork(.testnet)

                            } label: {
                                NetworkMenuItem(network: .testnet, currentNetwork: LocalUserDefaults.shared.flowNetwork)
                            }
                        }

                    } label: {
                        Text(LocalUserDefaults.shared.flowNetwork.rawValue.uppercasedFirstLetter())
                            .font(.inter(size: 12))
                            .foregroundStyle(LocalUserDefaults.shared.flowNetwork.color)
                            .frame(height: 24)
                            .padding(.horizontal, 8)
                            .background(LocalUserDefaults.shared.flowNetwork.color.opacity(0.08))
                            .cornerRadius(8)
                    }
                }
                .frame(height: 40)
            }

            Button {
                Router.route(to: RouteMap.RestoreLogin.restoreList)
            } label: {
                HStack {
                    Image("icon_side_import")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.Theme.Text.black8)
                    Text("import_wallet".localized)
                        .font(.inter(size: 14, weight: .semibold))
                        .foregroundStyle(Color.Theme.Text.black8)

                    Spacer()
                }
                .frame(height: 40)
            }
        }
    }
}

class SideContainerViewModel: ObservableObject {
    @Published var isOpen: Bool = false
    @Published var isLinkedAccount: Bool = false
    @Published var hideBrowser: Bool = false
    @Published @MainActor var isInsufficientStorageTransactionFailurePopupVisible = false
    var insufficientStorageTransactionFailurePopupData = InsufficientStorageTransactionFailureData()

    private var cancellableSet = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(onToggle), name: .toggleSideMenu, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onRemoteConfigDidChange), name: .remoteConfigDidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onInsufficientStorageTransactionFailure), name: .insufficientStorageTransactionFailure, object: nil)

        isLinkedAccount = ChildAccountManager.shared.selectedChildAccount != nil
        ChildAccountManager.shared.$selectedChildAccount
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink(receiveValue: { [weak self] newChildAccount in
                self?.isLinkedAccount = newChildAccount != nil
            }).store(in: &cancellableSet)
    }

    @objc func onToggle() {
        withAnimation {
            isOpen.toggle()
        }
    }

    @objc private func onRemoteConfigDidChange() {
        DispatchQueue.main.async {
            self.hideBrowser = RemoteConfigManager.shared.config?.features.hideBrowser ?? true
        }
    }
    
    @objc private func onInsufficientStorageTransactionFailure(notification: NSNotification) {
        DispatchQueue.main.async {
            self.isInsufficientStorageTransactionFailurePopupVisible = true
            if let data = notification.object as? InsufficientStorageTransactionFailureData {
                self.insufficientStorageTransactionFailurePopupData = data
            }
        }
    }
    
    func routeToBuyFlow() {
        Router.route(to: RouteMap.Wallet.receive)
    }
    
    func routeToDeposit() {
        Router.route(to: RouteMap.Wallet.buyCrypto)
    }
}

struct SideContainerView: View {
    @StateObject private var vm = SideContainerViewModel()
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false

    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                dragOffset = value.translation
                debugPrint("dragging: \(dragOffset)")
            }
            .onEnded { _ in
                if !vm.isOpen && dragOffset.width > 20 {
                    vm.isOpen = true
                }

                if vm.isOpen && dragOffset.width < -20 {
                    vm.isOpen = false
                }

                isDragging = false
                dragOffset = .zero
            }
    }

    var body: some View {
        ZStack {
            SideMenuView()
                .offset(x: vm.isOpen ? 0 : -(screenWidth - SideOffset))

            Group {
                makeTabView()

                Color.black
                    .opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        vm.onToggle()
                    }
                    .opacity(vm.isOpen ? 1.0 : 0.0)
            }
            .offset(x: vm.isOpen ? screenWidth - SideOffset : 0)
        }
        .customAlertView(
            isPresented: $vm.isInsufficientStorageTransactionFailurePopupVisible,
            title: .init("insufficient_storage::error::title".localized),
            customContentView: AnyView(
                VStack(alignment: .center, spacing: 8) {
                    Text(.init("insufficient_storage::error::content::first".localized))
                    Text(.init("insufficient_storage::error::content::second".localized(self.vm.insufficientStorageTransactionFailurePopupData.minimumBalance.doubleValue)))
                        .foregroundColor(Color.LL.Button.Warning.background)
                    Text(.init("insufficient_storage::error::content::third".localized))
                        .padding(.top, 8)
                }
                .padding(.vertical, 8)
            ),
            buttons: [
                AlertView.ButtonItem(type: .secondaryAction, title: "Deposit::message".localized, action: self.vm.routeToBuyFlow),
                AlertView.ButtonItem(type: .primaryAction, title: "buy_flow".localized, action: self.vm.routeToDeposit)
            ],
            useDefaultCancelButton: false,
            showCloseButton: true,
            buttonsLayout: .horizontal,
            textAlignment: .center

        )
    }

    @ViewBuilder private func makeTabView() -> some View {
        let wallet = TabBarPageModel<AppTabType>(tag: WalletView.tabTag(), iconName: WalletView.iconName(), color: WalletView.color()) {
            AnyView(WalletHomeView())
        }

        let nft = TabBarPageModel<AppTabType>(tag: NFTTabScreen.tabTag(), iconName: NFTTabScreen.iconName(), color: NFTTabScreen.color()) {
            AnyView(NFTTabScreen())
        }

        let explore = TabBarPageModel<AppTabType>(tag: ExploreTabScreen.tabTag(), iconName: ExploreTabScreen.iconName(), color: ExploreTabScreen.color()) {
            AnyView(ExploreTabScreen())
        }

        let profile = TabBarPageModel<AppTabType>(tag: ProfileView.tabTag(), iconName: ProfileView.iconName(), color: ProfileView.color()) {
            AnyView(ProfileView())
        }

        if vm.isLinkedAccount {
            TabBarView(current: .wallet, pages: [wallet, nft, profile], maxWidth: UIScreen.main.bounds.width)
        } else {
            if vm.hideBrowser {
                TabBarView(current: .wallet, pages: [wallet, nft, profile], maxWidth: UIScreen.main.bounds.width)
            } else {
                TabBarView(current: .wallet, pages: [wallet, nft, explore, profile], maxWidth: UIScreen.main.bounds.width)
            }
        }
    }
}
