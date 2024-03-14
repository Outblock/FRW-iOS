//
//  ProfileEditView.swift
//  Flow Wallet
//
//  Created by Selina on 14/6/2022.
//

import Kingfisher
import SwiftUI

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView()
    }
}

struct ProfileEditView: RouteableView {
    @StateObject private var vm = ProfileEditViewModel()
    
    var title: String {
        return "edit_account".localized
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                editContainer
//                domainEnabledView
//                claimDomainBanner
            }
        }
        .backgroundFill(.LL.Neutrals.background)
        .applyRouteable(self)
    }
    
    var editContainer: some View {
        VStack(spacing: 0) {
            editAvatarCell
            BaseDivider()
            editNicknameCell
            BaseDivider()
            editPrivateCell
        }
        .background(Color.LL.bgForIcon)
        .cornerRadius(16)
        .padding(.horizontal, 18)
    }
    
    var domainEnabledView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("domain_title2".localized)
                    .font(titleFont)
                    .foregroundColor(titleColor)
                
                Text(UserManager.shared.userInfo?.meowDomain ?? "")
                    .font(.inter(size: 12))
                    .foregroundColor(.LL.Neutrals.note)
            }
            
            Spacer()
            
            Image(systemName: .checkmarkSelected)
                .foregroundColor(Color.LL.Primary.salmonPrimary)
        }
        .frame(height: 70)
        .padding(.horizontal, 16)
        .background(Color.LL.bgForIcon)
        .cornerRadius(16)
        .padding(.horizontal, 18)
        .visibility(UserManager.shared.isMeowDomainEnabled ? .visible : .gone)
    }
    
    var claimDomainBanner: some View {
        Button {
            Router.route(to: RouteMap.Explore.claimDomain)
        } label: {
            ZStack {
                Image("banner-claim-domain")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                
                HStack(spacing: 0) {
                    Text("claim_free_domain_substring1".localized)
                        .font(Font.LL.miniTitle2)
                        .fontWeight(.w700)
                        .foregroundColor(.LL.Neutrals.text)
                    
                    Text("claim_free_domain_substring2".localized)
                        .font(Font.LL.miniTitle2)
                        .fontWeight(.w700)
                        .foregroundColor(.LL.Primary.salmonPrimary)
                    
                    Text("claim_free_domain_substring3".localized)
                        .font(Font.LL.miniTitle2)
                        .fontWeight(.w700)
                        .foregroundColor(.LL.Neutrals.text)
                    
                    Spacer()
                    
                    Text("domain_claim".localized)
                        .font(.inter(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(height: 30)
                        .padding(.horizontal, 15)
                        .background(Color.LL.Primary.salmonPrimary)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, 18)
        }
        .visibility(UserManager.shared.isMeowDomainEnabled ? .gone : .visible)
    }
}

extension ProfileEditView {
    var editAvatarCell: some View {
        HStack {
            Text("edit_avatar".localized)
                .font(titleFont)
                .foregroundColor(titleColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            KFImage.url(URL(string: vm.state.avatar))
                .placeholder({
                    Image("placeholder")
                        .resizable()
                })
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        }
        .padding(.horizontal, 16)
        .frame(height: 70)
        .onTapGestureOnBackground {
            vm.trigger(.editAvatar)
        }
    }

    var editNicknameCell: some View {
        HStack {
            Text("edit_nickname".localized)
                .font(titleFont)
                .foregroundColor(titleColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(vm.state.nickname)
                .font(.inter(size: 16, weight: .medium))
                .foregroundColor(.LL.Neutrals.note)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .onTapGestureOnBackground {
            Router.route(to: RouteMap.Profile.editName)
        }
    }

    var editPrivateCell: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("private".localized)
                    .font(titleFont)
                    .foregroundColor(titleColor)

                Text(vm.state.isPrivate ? "private_on_desc".localized : "private_off_desc".localized)
                    .font(.inter(size: 12))
                    .foregroundColor(.LL.Neutrals.note)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 24) {
                Button {
                    vm.trigger(.changePrivate(false))
                } label: {
                    VStack {
                        ZStack(alignment: .bottomTrailing) {
                            Image("icon-visible")
                            Image("icon-selected-small").visibility(vm.state.isPrivate ? .gone : .visible)
                                .padding(.trailing, -3)
                                .padding(.bottom, -3)
                        }

                        Text("visible".localized)
                            .font(.inter(size: 12))
                            .foregroundColor(.LL.Neutrals.note)
                    }
                }

                Button {
                    vm.trigger(.changePrivate(true))
                } label: {
                    VStack {
                        ZStack(alignment: .bottomTrailing) {
                            Image("icon-unvisible")
                            Image("icon-selected-small").visibility(vm.state.isPrivate ? .visible : .gone)
                                .padding(.trailing, -3)
                                .padding(.bottom, -3)
                        }

                        Text("unvisible".localized)
                            .font(.inter(size: 12))
                            .foregroundColor(.LL.Neutrals.note)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 88)
    }
}

extension ProfileEditView {
    var titleColor: Color {
        return .LL.Neutrals.text
    }

    var titleFont: Font {
        return .inter(size: 17, weight: .medium)
    }
}
