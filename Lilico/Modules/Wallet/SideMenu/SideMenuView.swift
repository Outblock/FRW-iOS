//
//  SideMenuView.swift
//  Lilico
//
//  Created by Selina on 4/1/2023.
//

import SwiftUI
import Kingfisher
import Combine

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
    
    private var cancelSets = Set<AnyCancellable>()
    
    init() {
        nftCount = LocalUserDefaults.shared.nftCount
        
        NotificationCenter.default.publisher(for: .nftCountChanged).sink { [weak self] noti in
            DispatchQueue.main.async {
                self?.nftCount = LocalUserDefaults.shared.nftCount
            }
        }.store(in: &cancelSets)
        
        UserManager.shared.$loginUIDList
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink { [weak self] uidList in
                guard let self = self else { return }
                
                self.accountPlaceholders = Array(uidList.dropFirst().prefix(2)).map({ uid in
                    let avatar = MultiAccountStorage.shared.getUserInfo(uid)?.avatar.convertedAvatarString() ?? ""
                    return AccountPlaceholder(uid: uid, avatar: avatar)
                })
            }.store(in: &cancelSets)
    }
    
    func scanAction() {
        NotificationCenter.default.post(name: .toggleSideMenu)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            ScanHandler.scan()
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
}

struct SideMenuView: View {
    @StateObject private var vm = SideMenuViewModel()
    @StateObject private var um = UserManager.shared
    @StateObject private var wm = WalletManager.shared
    @StateObject private var cm = ChildAccountManager.shared
    @AppStorage("isDeveloperMode") private var isDeveloperMode = false
    
    var body: some View {
        HStack(spacing: 0) {
            ScrollView {
                VStack {
                    cardView
                    scanView
                        .padding(.top, 24)
                    addressListView
                }
                .padding(.horizontal, 12)
                .padding(.top, 25)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.LL.background)
            
            // placeholder, do not use this
            VStack {
                
            }
            .frame(width: SideOffset)
            .frame(maxHeight: .infinity)
        }
    }
    
    var cardView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                KFImage.url(URL(string: um.userInfo?.avatar.convertedAvatarString() ?? ""))
                    .placeholder({
                        Image("placeholder")
                            .resizable()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 72, height: 72)
                    .cornerRadius(36)
                    .offset(y: -20)
                
                Spacer()
                
                multiAccountView
                    .offset(y: -30)
            }
            
            Text(um.userInfo?.nickname ?? "Lilico")
                .foregroundColor(.LL.Neutrals.text)
                .font(.inter(size: 24, weight: .semibold))
                .padding(.top, 10)
                .padding(.bottom, 5)
            
            Text("Since 2022 · \(vm.nftCount) NFTs")
                .foregroundColor(.LL.Neutrals.text3)
                .font(.inter(size: 14))
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            Color.LL.Neutrals.neutrals6
                .cornerRadius(12)
        }
    }
    
    var multiAccountView: some View {
        HStack(spacing: 15) {
            ForEach(vm.accountPlaceholders, id: \.uid) { placeholder in
                Button {
                    vm.switchAccountAction(placeholder.uid)
                } label: {
                    KFImage.url(URL(string: placeholder.avatar))
                        .placeholder({
                            Image("placeholder")
                                .resizable()
                        })
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 28, height: 28)
                        .cornerRadius(14)
                }
            }
            
            Button {
                vm.switchAccountMoreAction()
            } label: {
                Image("icon-more")
                    .renderingMode(.template)
                    .foregroundColor(Color.LL.Neutrals.text)
            }
        }
    }
    
    var scanView: some View {
        Button {
            vm.scanAction()
        } label: {
            HStack {
                Image("scan-stroke")
                    .renderingMode(.template)
                    .foregroundColor(Color.LL.Neutrals.text)
                
                Text("scan".localized)
                    .foregroundColor(Color.LL.Neutrals.text)
                    .font(.inter(size: 14, weight: .semibold))
                
                Spacer()
                
                Image("icon-right-arrow-1")
                    .renderingMode(.template)
                    .foregroundColor(Color.LL.Neutrals.text)
            }
            .padding(.horizontal, 20)
            .frame(height: 48)
            .background(Color.LL.Neutrals.neutrals6)
            .cornerRadius(12)
        }
    }
    
    var addressListView: some View {
        VStack(spacing: 0) {
            if let mainnetAddress = wm.getFlowNetworkTypeAddress(network: .mainnet) {
                Button {
                    WalletManager.shared.changeNetwork(.mainnet)
                    NotificationCenter.default.post(name: .toggleSideMenu)
                } label: {
                    addressCell(type: .mainnet, address: mainnetAddress, isSelected: LocalUserDefaults.shared.flowNetwork == .mainnet && !wm.isSelectedChildAccount)
                }
                
                if LocalUserDefaults.shared.flowNetwork == .mainnet {
                    LazyVStack(spacing: 0) {
                        ForEach(cm.childAccounts, id: \.addr) { childAccount in
                            childAccountCell(childAccount, isSelected: childAccount.isSelected)
                        }
                    }
                }
            }
            
            if let testnetAddress = wm.getFlowNetworkTypeAddress(network: .testnet), isDeveloperMode {
                Button {
                    WalletManager.shared.changeNetwork(.testnet)
                    NotificationCenter.default.post(name: .toggleSideMenu)
                } label: {
                    addressCell(type: .testnet, address: testnetAddress, isSelected: LocalUserDefaults.shared.flowNetwork == .testnet && !wm.isSelectedChildAccount)
                }
                
                if LocalUserDefaults.shared.flowNetwork == .testnet {
                    LazyVStack(spacing: 0) {
                        ForEach(cm.childAccounts, id: \.addr) { childAccount in
                            childAccountCell(childAccount, isSelected: childAccount.isSelected)
                        }
                    }
                }
            }
            
            if let sandboxAddress = wm.getFlowNetworkTypeAddress(network: .sandboxnet), isDeveloperMode {
                Button {
                    WalletManager.shared.changeNetwork(.sandboxnet)
                    NotificationCenter.default.post(name: .toggleSideMenu)
                } label: {
                    addressCell(type: .sandboxnet, address: sandboxAddress, isSelected: LocalUserDefaults.shared.flowNetwork == .sandboxnet)
                }
                
//                if LocalUserDefaults.shared.flowNetwork == .sandboxnet {
//                    LazyVStack(spacing: 0) {
//                        ForEach(cm.childAccounts, id: \.address) { childAccount in
//                            childAccountCell(childAccount, isSelected: false)
//                        }
//                    }
//                }
            }
        }
        .background(Color.LL.Neutrals.neutrals6)
        .cornerRadius(12)
    }
    
    func childAccountCell(_ childAccount: ChildAccount, isSelected: Bool) -> some View {
        Button {
            ChildAccountManager.shared.select(childAccount)
            NotificationCenter.default.post(name: .toggleSideMenu)
        } label: {
            HStack(spacing: 15) {
                KFImage.url(URL(string: childAccount.icon))
                    .placeholder({
                        Image("placeholder")
                            .resizable()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24)
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("@\(childAccount.aName)")
                            .foregroundColor(Color.LL.Neutrals.text)
                            .font(.inter(size: 14, weight: .semibold))
                    }
                    .frame(alignment: .leading)
                    
                    Text(childAccount.addr ?? "")
                        .foregroundColor(Color.LL.Neutrals.text3)
                        .font(.inter(size: 12))
                }
                .frame(alignment: .leading)
                
                Spacer()
                
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(Color(hex: "#00FF38"))
                    .visibility(isSelected ? .visible : .gone)
            }
            .frame(height: 66)
            .padding(.leading, 36)
            .padding(.trailing, 18)
            .background {
                selectedBg
                    .visibility(isSelected ? .visible : .gone)
            }
            .contentShape(Rectangle())
        }
    }
    
    func addressCell(type: LocalUserDefaults.FlowNetworkType, address: String, isSelected: Bool) -> some View {
        HStack(spacing: 15) {
            Image("flow")
                .resizable()
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("My Wallet")
                        .foregroundColor(Color.LL.Neutrals.text)
                        .font(.inter(size: 14, weight: .semibold))
                    
                    Text(type.rawValue)
                        .textCase(.uppercase)
                        .lineLimit(1)
                        .foregroundColor(Color(hex: "#333333"))
                        .font(.inter(size: 10, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule(style: .circular)
                                .fill(Color(hex: "#EAEAEA"))
                        )
                        .visibility(type == .mainnet ? .gone : .visible)
                }
                .frame(alignment: .leading)
                
                Text(address)
                    .foregroundColor(Color.LL.Neutrals.text3)
                    .font(.inter(size: 12))
            }
            .frame(alignment: .leading)
            
            Spacer()
            
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(Color(hex: "#00FF38"))
                .visibility(isSelected ? .visible : .gone)
        }
        .frame(height: 78)
        .padding(.horizontal, 18)
        .background {
            selectedBg
                .visibility(isSelected ? .visible : .gone)
        }
        .clipped()
    }
    
    var selectedBg: some View {
        LinearGradient(colors: [Color(hex: "#00FF38").opacity(0.08), Color(hex: "#00FF38").opacity(0)], startPoint: .leading, endPoint: .trailing)
    }
}

class SideContainerViewModel: ObservableObject {
    @Published var isOpen: Bool = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(onToggle), name: .toggleSideMenu, object: nil)
    }
    
    @objc func onToggle() {
        withAnimation {
            isOpen.toggle()
        }
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
            .onEnded { value in
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
    }
    
    @ViewBuilder private func makeTabView() -> some View {
        let wallet = TabBarPageModel<AppTabType>(tag: WalletView.tabTag(), iconName: WalletView.iconName(), color: WalletView.color()) {
            AnyView(WalletView())
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

        TabBarView(current: .wallet, pages: [wallet, nft, explore, profile], maxWidth: UIScreen.main.bounds.width)
    }
}
