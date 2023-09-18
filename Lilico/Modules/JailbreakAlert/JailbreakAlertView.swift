//
//  JailbreakAlertView.swift
//  Flow Reference Wallet
//
//  Created by Selina on 20/7/2023.
//

import SwiftUI
import Combine

struct JailbreakAlertView: View {
    var body: some View {
        VStack {
            SheetHeaderView(title: "jailbreak_title".localized)
            
            Text("jailbreak_desc".localized)
                .font(.inter(size: 14, weight: .regular))
                .foregroundColor(Color.LL.Neutrals.text2)
                .multilineTextAlignment(.center)
            
            noticePanel
                .padding(.all, 18)
            
            Spacer()
            
            buttonView
                .padding(.horizontal, 18)
                .padding(.bottom, 20)
        }
        .backgroundFill(Color.LL.Neutrals.background)
    }
    
    var noticePanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("things_you_need_to_know".localized.uppercased())
                .font(.inter(size: 14, weight: .medium))
                .foregroundColor(Color.LL.Neutrals.note)
                .padding(.bottom, 18)
            
            createNoticeDetailView(text: "jailbreak_tips_0".localized)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(Color.LL.Other.bg1)
        .cornerRadius(12)
    }
    
    func createNoticeDetailView(text: String) -> some View {
        HStack(spacing: 12) {
            Image("icon-warning-mark")
                .renderingMode(.template)
                .foregroundColor(Color.LL.Warning.warning2)
            
            Text(text)
                .font(.inter(size: 14, weight: .medium))
                .foregroundColor(Color.LL.Neutrals.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
        }
    }
    
    var buttonView: some View {
        Button {
            Router.dismiss()
        } label: {
            Text("understand_btn_title".localized)
                .foregroundColor(Color.LL.Button.text)
                .font(.inter(size: 14, weight: .bold))
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .background(Color.LL.Button.color)
                .cornerRadius(12)
        }
    }
}
