//
//  DeveloperModeView.swift
//  Flow Wallet
//
//  Created by Selina on 7/6/2022.
//

import SwiftUI

struct DeveloperModeView_Previews: PreviewProvider {
    static var previews: some View {
        DeveloperModeView()
    }
}

struct DeveloperModeView: RouteableView {
    @StateObject private var lud = LocalUserDefaults.shared
    @StateObject private var vm: DeveloperModeViewModel = DeveloperModeViewModel()
    @StateObject private var walletManager = WalletManager.shared
    
    @AppStorage("isDeveloperMode") private var isDeveloperMode = false
    
    var title: String {
        return "developer_mode".localized
    }
    
    var body: some View {
        
        ScrollView {
            VStack {
                HStack {
                    Toggle("developer_mode".localized, isOn: $isDeveloperMode)
                        .toggleStyle(SwitchToggleStyle(tint: .LL.Primary.salmonPrimary))
                }
                .frame(height: 64)
                .padding(.horizontal, 16)
            }
            .background(.LL.bgForIcon)
            .cornerRadius(16)
            .padding(.horizontal, 18)
            
            if isDeveloperMode {
                
                VStack {
                    Text("switch_network".localized)
                        .font(.LL.footnote)
                        .foregroundColor(.LL.Neutrals.neutrals3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(spacing: 0) {
                        Section {
                            let isMainnet = lud.flowNetwork == .mainnet
                            let isTestnet = lud.flowNetwork == .testnet
                            let isCrescendo = lud.flowNetwork == .crescendo
                            
                            Cell(sysImageTuple: (isMainnet ? .checkmarkSelected : .checkmarkUnselected, isMainnet ? .LL.Primary.salmonPrimary : .LL.Neutrals.neutrals1), title: "Mainnet", desc: isMainnet ? "Selected" : "")
                                .onTapGestureOnBackground {
                                    walletManager.changeNetwork(.mainnet)
                                }
                            
                            Divider()
                            Cell(sysImageTuple: (isTestnet ? .checkmarkSelected : .checkmarkUnselected, isTestnet ? LocalUserDefaults.FlowNetworkType.testnet.color : .LL.Neutrals.neutrals1), title: "Testnet", desc: isTestnet ? "Selected" : "")
                                .onTapGestureOnBackground {
                                    walletManager.changeNetwork(.testnet)
                                }
                            
                            Divider()
                            Cell(sysImageTuple: (isCrescendo ? .checkmarkSelected : .checkmarkUnselected, isCrescendo ? LocalUserDefaults.FlowNetworkType.crescendo.color : .LL.Neutrals.neutrals1), title: "Crescendo", desc: isCrescendo ? "Selected" : "", btnTitle: walletManager.isCrescendoEnabled ? nil : "Enable", btnAction: {
                                if !walletManager.isCrescendoEnabled {
                                    vm.enableCrescendoAction()
                                }
                            }, titleAlpha: walletManager.isCrescendoEnabled ? 1 : 0.5)
                                .onTapGestureOnBackground {
                                    if walletManager.isCrescendoEnabled {
                                        walletManager.changeNetwork(.crescendo)
                                    }
                                }
                        }
                        .background(.LL.bgForIcon)
                    }
                    .cornerRadius(16)
                    
                    Text("watch_address".localized)
                        .font(.LL.footnote)
                        .foregroundColor(.LL.Neutrals.neutrals3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(spacing: 0) {
                        Section {
                            Cell(sysImageTuple: (vm.isCustomAddress ? .checkmarkUnselected : .checkmarkSelected, vm.isCustomAddress ? .LL.Neutrals.neutrals1 : .LL.Primary.salmonPrimary), title: "my_own_address".localized, desc: "")
                                .onTapGestureOnBackground {
                                    vm.changeCustomAddressAction("")
                                }
                            
                            Divider()
                            
                            Cell(sysImageTuple: (vm.isDemoAddress ? .checkmarkSelected : .checkmarkUnselected, vm.isDemoAddress ? .LL.Primary.salmonPrimary : .LL.Neutrals.neutrals1), title: vm.demoAddress, desc: "")
                                .onTapGestureOnBackground {
                                    vm.changeCustomAddressAction(vm.demoAddress)
                                }
                            
                            Divider()
                            
                            Cell(sysImageTuple: (vm.isSVGDemoAddress ? .checkmarkSelected : .checkmarkUnselected, vm.isSVGDemoAddress ? .LL.Primary.salmonPrimary : .LL.Neutrals.neutrals1), title: vm.svgDemoAddress, desc: "")
                                .onTapGestureOnBackground {
                                    vm.changeCustomAddressAction(vm.svgDemoAddress)
                                }
                            
                            Divider()
                            
                            HStack {
                                Image(systemName: vm.isCustomAddress ? .checkmarkSelected : .checkmarkUnselected)
                                    .foregroundColor(vm.isCustomAddress ? .LL.Primary.salmonPrimary : .LL.Neutrals.neutrals1)
                                Text("custom_address".localized)
                                    .font(.inter())
                                
                                TextField("", text: $vm.customAddressText)
                                    .autocorrectionDisabled()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .padding(.horizontal, 10)
                                    .background(.LL.Neutrals.background)
                                    .cornerRadius(8)
                                    .onChange(of: vm.customAddressText) { _ in
                                        let trimedAddress = vm.customAddressText.trim()
                                        if trimedAddress == vm.customWatchAddress {
                                            return
                                        }
                                        
                                        DispatchQueue.main.async {
                                            vm.changeCustomAddressAction(vm.customAddressText.trim())
                                        }
                                    }
                            }
                            .frame(height: 64)
                            .padding(.horizontal, 16)
                            
                        }
                        .background(.LL.bgForIcon)
                    }
                    .cornerRadius(16)
                }
                .padding(.horizontal, 18)
            }
        }
        .background(
            Color.LL.Neutrals.background.ignoresSafeArea()
        )
        .applyRouteable(self)
    }
}

extension DeveloperModeView {
    struct Cell: View {
        let sysImageTuple: (String, Color)
        let title: String
        let desc: String
        var btnTitle: String? = nil
        var btnAction: (() -> ())? = nil
        var titleAlpha: Double = 1.0
        
        var body: some View {
            HStack {
                Image(systemName: sysImageTuple.0).foregroundColor(sysImageTuple.1)
                Text(title).font(.inter()).frame(maxWidth: .infinity, alignment: .leading).opacity(titleAlpha)
                Text(desc).font(.inter()).foregroundColor(.LL.Neutrals.note)
                
                Button {
                    if let btnAction = btnAction {
                        btnAction()
                    }
                } label: {
                    Text(btnTitle ?? "")
                        .font(.inter(size: 12, weight: .medium))
                        .foregroundColor(Color.black)
                        .padding(.horizontal, 12)
                        .frame(height: 32)
                        .background(Color(hex: "#F3EA5F"))
                        .cornerRadius(16)
                }
                .visibility(btnTitle?.isEmpty ?? true ? .gone : .visible)
            }
            .frame(height: 64)
            .padding(.horizontal, 16)
        }
    }
}
