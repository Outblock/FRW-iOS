//
//  AccountSwitchView.swift
//  Flow Wallet
//
//  Created by Selina on 13/6/2023.
//

import SwiftUI
import Combine
import Kingfisher

struct AccountSwitchView: View {
    @StateObject private var vm = AccountSwitchViewModel()
    
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
                .padding(.bottom, 30)
            
            Button {
                Router.dismiss {
                    vm.createNewAccountAction()
                }
            } label: {
                HStack(spacing: 15) {
                    Image("icon-plus")
                        .renderingMode(.template)
                        .foregroundColor(Color.LL.Neutrals.text)
                        .frame(width: 14, height: 14)
                    
                    Text("create_new_account".localized)
                        .font(.inter(size: 14, weight: .semibold))
                        .foregroundColor(Color.LL.Neutrals.text)
                    
                    Spacer()
                }
                .frame(height: 40)
            }
            
            Button {
                Router.dismiss {
                    vm.loginAccountAction()
                }
            } label: {
                HStack(spacing: 15) {
                    Image("icon-down-arrow")
                        .renderingMode(.template)
                        .foregroundColor(Color.LL.Neutrals.text)
                        .frame(width: 14, height: 14)
                    
                    Text("add_existing_account".localized)
                        .font(.inter(size: 14, weight: .semibold))
                        .foregroundColor(Color.LL.Neutrals.text)
                    
                    Spacer()
                }
                .frame(height: 40)
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
                        Router.dismiss {
                            vm.switchAccountAction(placeholder.uid)
                        }
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
