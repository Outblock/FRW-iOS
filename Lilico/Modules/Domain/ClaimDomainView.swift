//
//  ClaimDomainView.swift
//  Lilico
//
//  Created by Selina on 15/9/2022.
//

import SwiftUI

struct ClaimDomainView: RouteableView {
    @StateObject private var vm: ClaimDomainViewModel = ClaimDomainViewModel()
    
    var title: String {
        return "free_domain".localized
    }
    
    var buttonState: VPrimaryButtonState {
        if vm.isRequesting {
            return .loading
        }
        return .enabled
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerView
                    descView
                    
                    Spacer()
                    
                }
            }
            .offset(y: 10)
            confirmBtn
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.LL.Neutrals.background)
        .applyRouteable(self)
    }
}

extension ClaimDomainView {
    var confirmBtn: some View {
        VPrimaryButton(model: ButtonStyle.primary, state: buttonState, action: {
            vm.claimAction()
        }, title: buttonState == .loading ? "working_on_it".localized : "domain_claim".localized)
        .padding(.horizontal, 18)
        .padding(.bottom, 18)
    }
}

extension ClaimDomainView {
    var descView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("things_you_should_known".localized)
                .font(.inter(size: 16, weight: .medium))
                .foregroundColor(Color.LL.Other.text1)
                .padding(.vertical, 20)
            
            createDescDetailView(text: "domain_tips1".localized)
                .padding(.bottom, 16)
            
            createDescDetailView(text: "domain_tips2".localized)
                .padding(.bottom, 16)
            
            createDescDetailView(text: "domain_tips3".localized, isWarning: true)
                .padding(.bottom, 16)
        }
        .padding(.horizontal, 18)
    }
    
    func createDescDetailView(text: String, isWarning: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(isWarning ? "icon-warning-mark" : "icon-right-mark")
            
            Text(text)
                .font(.inter(size: 14))
                .foregroundColor(Color.LL.Neutrals.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(3)
        }
    }
}

extension ClaimDomainView {
    var headerView: some View {
        ZStack {
            Image("bg-domain-claim-header")
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            VStack (spacing: 24) {
                headerTitleView
                headerDomainView
            }
            .padding(.horizontal, 18)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 170)
    }
    
    var headerTitleView: some View {
        HStack(spacing: 0) {
            Image("lilico-app-icon")
                .resizable()
                .frame(width: 24, height: 24)
                .clipShape(Circle())
            
            Text("lilico".localized)
                .font(.inter(size: 16, weight: .bold))
                .foregroundColor(.LL.Neutrals.text)
                .padding(.leading, 3)
            
            Image("icon-domain-x")
                .padding(.horizontal, 12)
            
            Image("icon-flowns")
                .resizable()
                .frame(width: 24, height: 24)
                .clipShape(Circle())
            
            Text("flowns".localized)
                .font(.inter(size: 16, weight: .bold))
                .foregroundColor(.LL.Neutrals.text)
                .padding(.leading, 3)
        }
    }
    
    var headerDomainView: some View {
        ZStack {
            HStack (spacing: 0) {
                Text(vm.username ?? "")
                    .font(Font.LL.mindTitle)
                    .fontWeight(.w600)
                    .foregroundColor(Color.LL.Neutrals.text)
                
                Text(".meow")
                    .font(Font.LL.mindTitle)
                    .fontWeight(.w600)
                    .foregroundColor(Color.LL.Primary.salmonPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .padding(.horizontal, 18)
        .roundedBg(cornerRadius: 16, fillColor: Color.LL.Neutrals.background, strokeColor: Color.LL.Primary.salmonPrimary, strokeLineWidth: 1)
    }
}
