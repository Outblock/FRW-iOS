//
//  AccountSwitchView.swift
//  Lilico
//
//  Created by Selina on 13/6/2023.
//

import SwiftUI
import Combine
import Kingfisher

struct AccountSwitchView: View {
    @StateObject private var vm = AccountSwitchViewModel()
    @EnvironmentObject var sideVM: SideMenuViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            titleView
                .padding(.vertical, 36)
            
            contentView
            
            bottomView
                .padding(.top, 7)
        }
        .backgroundFill(Color.LL.Neutrals.background)
    }
    
    var titleView: some View {
        Text("accounts".localized)
            .font(.inter(size: 24, weight: .bold))
            .foregroundColor(Color.LL.Neutrals.text)
    }
    
    var bottomView: some View {
        VStack(spacing: 0) {
            Divider()
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.LL.Neutrals.background)
                .padding(.bottom, 36)
            
            Button {
                sideVM.switchAccountListPresent = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    vm.createNewAccountAction()
                }
            } label: {
                Text("create_new_account".localized)
                    .font(.inter(size: 17, weight: .semibold))
                    .foregroundColor(Color.LL.frontColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.LL.rebackground)
                    .cornerRadius(14)
            }
            .padding(.bottom, 20)
            
            Button {
                sideVM.switchAccountListPresent = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    vm.loginAccountAction()
                }
            } label: {
                Text("add_existing_account".localized)
                    .font(.inter(size: 17, weight: .regular))
                    .foregroundColor(Color.LL.Neutrals.text2)
            }
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 20)
    }
    
    var contentView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 20) {
                ForEach(vm.placeholders, id: \.uid) { placeholder in
                    Button {
                        sideVM.switchAccountListPresent = false
                        vm.switchAccountAction(placeholder.uid)
                    } label: {
                        createAccountCell(placeholder)
                    }
                }
            }
        }
        .padding(.horizontal, 28)
    }
    
    func createAccountCell(_ placeholder: AccountSwitchViewModel.Placeholder) -> some View {
        HStack(spacing: 16) {
            KFImage.url(URL(string: placeholder.avatar.convertedAvatarString()))
                .placeholder({
                    Image("placeholder")
                        .resizable()
                })
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 32, height: 32)
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("@\(placeholder.username)")
                    .font(.inter(size: 14, weight: .semibold))
                    .foregroundColor(Color.LL.Neutrals.text)
                
                Text("\(placeholder.address)")
                    .font(.inter(size: 12, weight: .regular))
                    .foregroundColor(Color.LL.Neutrals.text2)
            }
            
            Spacer()
            
            Image("icon-backup-success")
                .visibility(placeholder.uid == UserManager.shared.activatedUID ? .visible : .invisible)
        }
        .frame(height: 42)
        .contentShape(Rectangle())
    }
}
