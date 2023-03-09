//
//  AboutView.swift
//  Lilico
//
//  Created by Hao Fu on 20/9/2022.
//

import SwiftUI

struct AboutView: RouteableView {
    
    let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    let buildVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var title: String {
        "About"
    }
    
    var body: some View {
        VStack(alignment: .center) {
            
            Image("logo")
                .resizable()
                .frame(width: 100, height: 100)
                .padding(.top, 20)
            
            Text("lilico")
                .textCase(.lowercase)
                .font(.inter(size: 26, weight: .semibold))
            
            HStack {
                Text("version")
                    .textCase(.lowercase)
                
                Text("\(buildVersion ?? "") (\(version ?? ""))")
                    .textCase(.lowercase)
            }
            .font(.inter(size: 13, weight: .regular))
            .foregroundColor(.LL.note.opacity(0.5))
            .padding(.bottom, 50)
            
            
            Section {
                VStack(spacing: 0) {
                    
                    SocialButton(imageName: "disocrd",
                                 text: "Disocrd") {
                        UIApplication.shared.open(URL(string: "https://discord.gg/sfQKARA3SA")!)
                    }
                    
                    SocialButton(imageName: "twitter",
                                 text: "Twitter") {
                        UIApplication.shared.open(URL(string: "https://twitter.com/lilico_app")!)
                    }
                    
                    SocialButton(imageName: "email",
                                 text: "Email",
                                 showDivider: false) {
                        UIApplication.shared.open(URL(string: "mailto:hi@lilico.app")!)
                    }
                }
                .cornerRadius(16)
            } header: {
                Text("contact_us".localized)
                    .textCase(.uppercase)
                    .font(.inter(size: 14, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.LL.note)
            }
            
            Section {
                VStack(spacing: 0) {
                    
                    SocialButton(imageName: "logo",
                                 text: "Lilico Extension",
                                 showDivider: false) {
                        UIApplication.shared.open(URL(string: "https://chrome.google.com/webstore/detail/lilico/hpclkefagolihohboafpheddmmgdffjm")!)
                    }
                    
                }
                .cornerRadius(16)
            } header: {
                Text("more".localized)
                    .textCase(.uppercase)
                    .font(.inter(size: 14, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.LL.note)
                    .padding(.top, 20)
            }
            

            Spacer()
            
            Image("outblock-logo")
                .resizable()
                .frame(width: 50, height: 50)
                .onTapGesture {
                    UIApplication.shared.open(URL(string: "https://outblock.io")!)
                }
            
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .frame(maxHeight:.infinity, alignment: .top)
        .backgroundFill(.LL.background)
        .applyRouteable(self)
    }
    
    struct SocialButton: View {
        let imageName: String
        let text: String
        var showDivider: Bool = true
        let action: () -> Void
        
        var body: some View {
            VStack(spacing: 0) {
                Button {
                    action()
                } label: {
                    HStack {
                        Image(imageName)
                            .resizable()
                            .frame(width: 35, height: 35)
                        
                        Text(text)
                            .font(.LL.body)
                            .foregroundColor(.LL.text)
                            
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.LL.body)
                            .foregroundColor(.LL.note)
                    }
                    .padding(18)
                    
                }
                
                if showDivider {
                    Divider()
                        .background(.LL.bgForIcon)
                        .padding(.horizontal, 12)
                }
            }
            .background(.LL.bgForIcon)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
