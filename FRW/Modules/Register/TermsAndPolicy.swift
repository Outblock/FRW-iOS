//
//  TermsAndPolicy.swift
//  Flow Reference Wallet
//
//  Created by Hao Fu on 24/12/21.
//

import SwiftUI

struct TermsAndPolicy: RouteableView {
    let mnemonic: String?
    
    var title: String {
        return ""
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading) {
                Text("legal".localized)
                    .font(.LL.largeTitle)
                    .bold()
                    .foregroundColor(Color.LL.orange)
                Text("information".localized)
                    .font(.LL.largeTitle)
                    .bold()
                    .foregroundColor(Color.LL.rebackground)
                Text("review_policy_tips".localized)
                    .lineSpacing(5)
                    .font(.LL.body)
                    .foregroundColor(Color.LL.note)
                    .padding(.top, 1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            
            VStack(alignment: .leading) {
                Link(destination: URL(string: "https://lilico.app/about/terms")!) {
                    Text("terms_of_service".localized)
                        .fontWeight(.semibold)
                        .font(.LL.body)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(Font.caption2.weight(.bold))
                }.padding()
                
                Divider().foregroundColor(Color.LL.outline)
                
                Link(destination: URL(string: "https://lilico.app/about/privacy-policy")!) {
                    Text("privacy_policy".localized)
                        .font(.LL.body)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(Font.caption2.weight(.bold))
                }.padding()
            }
            .foregroundColor(Color.LL.text)
            
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.LL.outline,
                            lineWidth: 1)
            )
            .padding(.bottom, 40)
            
            VPrimaryButton(model: ButtonStyle.primary,
                           action: {
                Router.route(to: RouteMap.Register.username(mnemonic))
            }, title: "i_accept".localized)
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 28)
        .background(Color.LL.background, ignoresSafeAreaEdges: .all)
        .applyRouteable(self)
    }
}

struct TermsAndPolicy_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndPolicy(mnemonic: nil)
    }
}
