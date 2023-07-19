//
//  ChildAccountDetailView.swift
//  Lilico
//
//  Created by Selina on 21/6/2023.
//

import SwiftUI
import Combine
import Kingfisher
import UIKit

class ChildAccountDetailViewModel: ObservableObject {
    @Published var childAccount: ChildAccount
    @Published var isPresent: Bool = false
    private var isUnlinking: Bool = false
    
    init(childAccount: ChildAccount) {
        self.childAccount = childAccount
    }
    
    func copyAction() {
        UIPasteboard.general.string = childAccount.addr
        HUD.success(title: "copied".localized)
    }
    
    func unlinkConfirmAction() {
        if !checkChildAcountExist() {
            Router.pop()
            return
        }
        
        if checkUnlinkingTransactionIsProcessing() {
            return
        }
        
        if self.isPresent {
            self.isPresent = false
        }
        
        self.isPresent = true
    }
    
    private func checkChildAcountExist() -> Bool {
        return ChildAccountManager.shared.childAccounts.contains(where: { $0.addr == childAccount.addr })
    }
    
    private func checkUnlinkingTransactionIsProcessing() -> Bool {
        for holder in TransactionManager.shared.holders {
            if holder.type == .unlinkAccount, holder.internalStatus == .pending,
               let holderModel = try? JSONDecoder().decode(ChildAccount.self, from: holder.data),
               holderModel.addr == self.childAccount.addr {
                return true
            }
        }
        
        return false
    }
    
    func doUnlinkAction() {
        if isUnlinking {
            return
        }
        
        isUnlinking = true
        
        Task {
            do {
                let txId = try await FlowNetwork.unlinkChildAccount(childAccount.addr ?? "")
                let data = try JSONEncoder().encode(self.childAccount)
                let holder = TransactionManager.TransactionHolder(id: txId, type: .unlinkAccount, data: data)
                
                DispatchQueue.main.async {
                    TransactionManager.shared.newTransaction(holder: holder)
                    self.isUnlinking = false
                    self.isPresent = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        Router.pop()
                    }
                }
            } catch {
                log.error("unlink failed", context: error)
                DispatchQueue.main.async {
                    self.isUnlinking = false
                    self.isPresent = false
                }
                
                HUD.error(title: "request_failed".localized)
            }
        }
    }
    
    @objc func editChildAccountAction() {
        Router.route(to: RouteMap.Profile.editChildAccount(childAccount))
    }
}

struct ChildAccountDetailView: RouteableView {
    @StateObject var vm: ChildAccountDetailViewModel
    
    init(vm: ChildAccountDetailViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var title: String {
        "linked_account".localized
    }
    
    func configNavigationItem(_ navigationItem: UINavigationItem) {
        let editButton = UIBarButtonItem(image: UIImage(named: "icon-edit-child-account"), style: .plain, target: vm, action: Selector("editChildAccountAction"))
        editButton.tintColor = UIColor(named: "button.color")
        navigationItem.rightBarButtonItem = editButton
    }
    
    var body: some View {
        VStack(spacing: 20) {
            contentView
            unlinkBtn
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
        .backgroundFill(Color.LL.Neutrals.background)
        .applyRouteable(self)
        .halfSheet(showSheet: $vm.isPresent) {
            UnlinkConfirmView()
                .environmentObject(vm)
        }
    }
    
    var unlinkBtn: some View {
        Button {
            vm.unlinkConfirmAction()
        } label: {
            Text("unlink_account".localized)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(.LL.Warning.warning2)
                .cornerRadius(16)
                .foregroundColor(Color.white)
                .font(.inter(size: 16, weight: .semibold))
        }
    }
    
    var contentView: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                KFImage.url(URL(string: vm.childAccount.icon))
                    .placeholder({
                        Image("placeholder")
                            .resizable()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .cornerRadius(50)
                    .padding(.vertical, 20)
                
                Text(vm.childAccount.aName)
                    .foregroundColor(Color.LL.Neutrals.text)
                    .font(.inter(size: 18, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                
                addressContentView
                    .padding(.bottom, 20)
                
                descContentView
                    .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
    
    var addressContentView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("address".localized)
                .foregroundColor(Color.LL.Neutrals.text4)
                .font(.inter(size: 16, weight: .semibold))
            
            HStack {
                Text(vm.childAccount.addr ?? "")
                    .foregroundColor(Color.LL.Neutrals.text)
                    .font(.inter(size: 16, weight: .medium))
                
                Spacer()
                
                Button {
                    vm.copyAction()
                } label: {
                    Image("icon-copy")
                        .frame(width: 56, height: 48)
                        .contentShape(Rectangle())
                }
            }
            .frame(height: 48)
            .padding(.leading, 15)
            .background(Color.LL.Neutrals.neutrals6)
            .cornerRadius(16)
        }
    }
    
    var descContentView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("description".localized)
                .foregroundColor(Color.LL.Neutrals.text4)
                .font(.inter(size: 16, weight: .semibold))
            
            Text(vm.childAccount.description ?? "")
                .foregroundColor(Color.LL.Neutrals.text2)
                .font(.inter(size: 14, weight: .medium))
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension ChildAccountDetailView {
    struct Indicator: View {
        var styleColor: Color {
            return Color(hex: "#CCCCCC")
        }
        
        var barColors: [Color] {
            return [.clear, styleColor]
        }
        
        var body: some View {
            HStack(spacing: 0) {
                dotView
                lineView(start: .leading, end: .trailing)
                shortLine
                    .padding(.horizontal, 4)
                
                Image("unlink-indicator")
                    .renderingMode(.template)
                    .foregroundColor(styleColor)
                
                shortLine
                    .padding(.horizontal, 4)
                lineView(start: .trailing, end: .leading)
                dotView
            }
            .frame(width: 114, height: 8)
        }
        
        var shortLine: some View {
            Rectangle()
                .frame(width: 4, height: 2)
                .foregroundColor(styleColor)
        }
        
        func lineView(start: UnitPoint, end: UnitPoint) -> some View {
            LinearGradient(colors: barColors, startPoint: start, endPoint: end)
                .frame(height: 2)
                .frame(maxWidth: .infinity)
        }
        
        var dotView: some View {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(styleColor)
        }
    }
    
    struct ChildAccountTargetView: View {
        @State var iconURL: String
        @State var name: String
        @State var address: String
        
        var body: some View {
            VStack(spacing: 8) {
                KFImage.url(URL(string: iconURL))
                    .placeholder({
                        Image("placeholder")
                            .resizable()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .cornerRadius(20)
                
                Text(name)
                    .font(.inter(size: 10, weight: .semibold))
                    .foregroundColor(Color.LL.Neutrals.text)
                    .lineLimit(1)
                
                Text(address)
                    .font(.inter(size: 10, weight: .medium))
                    .foregroundColor(.LL.Neutrals.note)
                    .lineLimit(1)
            }
            .frame(width: 120)
        }
    }
    
    struct UnlinkConfirmView: View {
        @EnvironmentObject private var vm: ChildAccountDetailViewModel
        
        var body: some View {
            VStack {
                SheetHeaderView(title: "unlink_confirmation".localized)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    ZStack {
                        fromToView
                        ChildAccountDetailView.Indicator()
                            .padding(.bottom, 38)
                    }
                    .background(Color.LL.background)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), x: 0, y: 4, blur: 16)
                    .padding(.horizontal, 18)
                    
                    descView
                        .padding(.top, -20)
                        .padding(.horizontal, 28)
                        .zIndex(-1)
                    
                    Spacer()
                    
                    confirmButton
                        .padding(.bottom, 10)
                        .padding(.horizontal, 28)
                }
            }
            .backgroundFill(Color.LL.Neutrals.background)
        }

        var fromToView: some View {
            HStack {
                ChildAccountTargetView(iconURL: vm.childAccount.icon, name: vm.childAccount.aName, address: vm.childAccount.addr ?? "")
                
                Spacer()
                
                ChildAccountTargetView(iconURL: UserManager.shared.userInfo?.avatar.convertedAvatarString() ?? "", name: UserManager.shared.userInfo?.meowDomain ?? "", address: WalletManager.shared.getPrimaryWalletAddress() ?? "0x")
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
        }
        
        var descView: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("unlink_account".localized.uppercased())
                    .font(.inter(size: 14, weight: .semibold))
                    .foregroundColor(Color.LL.Neutrals.text4)
                
                Text("unlink_account_desc_x".localized(vm.childAccount.aName))
                    .font(.inter(size: 14, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text2)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 18)
            .padding(.top, 44)
            .padding(.bottom, 34)
            .background(Color.LL.Neutrals.neutrals6)
            .cornerRadius(16)
        }
        
        var confirmButton: some View {
            WalletSendButtonView(buttonText: "hold_to_unlink".localized) {
                vm.doUnlinkAction()
            }
        }
    }
}
