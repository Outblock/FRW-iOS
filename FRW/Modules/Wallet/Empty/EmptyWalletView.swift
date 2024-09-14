//
//  EmptyWalletView.swift
//  Flow Wallet
//
//  Created by Hao Fu on 25/12/21.
//

import Kingfisher
import SceneKit
import SPConfetti
import SwiftUI
import SwiftUIX

struct EmptyWalletView: View {
    @StateObject private var vm = EmptyWalletViewModel()
    
    @State private var isSettingNotificationFirst = true
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            topContent
                .padding(.horizontal, 30)
                
            Spacer()
            recentListContent
                .padding(.horizontal, 41)
                .visibility(vm.placeholders.isEmpty ? .gone : .visible)
            
            bottomContent
                .padding(.horizontal, 41)
                .padding(.bottom, 80)
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.LL.background)
        .onAppear(perform: {
            if !self.isSettingNotificationFirst {
                self.vm.tryToRestoreAccountWhenFirstLaunch()
            }
            self.isSettingNotificationFirst = false
        })
    }
    
    var topContent: some View {
        VStack(spacing: 0) {
            Image("lilico-app-icon")
                .resizable()
                .padding(15)
                .frame(width: 160, height: 160)
            VStack(spacing: 12) {
                Text("app_name_full".localized)
                    .font(.Ukraine(size: 24, weight: .bold))
                    .foregroundColor(Color.LL.text)
                
                Text("welcome_sub_desc".localized)
                    .font(.Ukraine(size: 16, weight: .light))
                    .foregroundColor(.LL.note)
            }
        }
    }
    
    var bottomContent: some View {
        VStack(spacing: 24) {
            Button {
                vm.createNewAccountAction()
            } label: {
                ZStack {
                    HStack(spacing: 8) {
                        Image("wallet-create-icon")
                            .frame(width: 24, height: 24)
                        
                        Text("create_wallet".localized)
                            .font(.inter(size: 17, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(height: 58)
                .frame(maxWidth: .infinity)
                .background(Color.LL.Primary.salmonPrimary)
                .contentShape(Rectangle())
                .cornerRadius(29)
                .shadow(color: Color.black.opacity(0.12), x: 0, y: 4, blur: 24)
            }
            
            Button {
                vm.loginAccountAction()
            } label: {
                ZStack {
                    HStack(spacing: 8) {
                        Image("wallet-login-icon")
                            .frame(width: 24, height: 24)
                        
                        Text("import_wallet".localized)
                            .font(.inter(size: 17, weight: .bold))
                            .foregroundColor(Color(hex: "#333333"))
                    }
                }
                .frame(height: 58)
                .frame(maxWidth: .infinity)
                .background(.white)
                .contentShape(Rectangle())
                .cornerRadius(29)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.black, lineWidth: 1.5)
                )
//                .shadow(color: Color.black.opacity(0.08), x: 0, y: 4, blur: 24)
            }
        }
    }
    
    var recentListContent: some View {
        VStack(spacing: 16) {
            Text("registerd_accounts".localized)
                .font(.inter(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(vm.placeholders, id: \.uid) { placeholder in
                        Button {
                            vm.switchAccountAction(placeholder.uid)
                        } label: {
                            createRecentLoginCell(placeholder)
                        }
                    }
                }
            }
            .frame(maxHeight: 196)
        }
    }
    
    func createRecentLoginCell(_ placeholder: EmptyWalletViewModel.Placeholder) -> some View {
        HStack(spacing: 16) {
            KFImage.url(URL(string: placeholder.avatar.convertedAvatarString()))
                .placeholder {
                    Image("placeholder")
                        .resizable()
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 36, height: 36)
                .cornerRadius(18)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("@\(placeholder.username)")
                    .font(.inter(size: 12, weight: .bold))
                    .foregroundStyle(Color.Theme.Text.black8)
                
                Text("\(placeholder.address)")
                    .font(.inter(size: 12, weight: .regular))
                    .foregroundStyle(Color.Theme.Text.black3)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(Color.Theme.Line.line)
        .contentShape(Rectangle())
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), x: 0, y: 4, blur: 16)
    }
}

#Preview {
    EmptyWalletView()
}
