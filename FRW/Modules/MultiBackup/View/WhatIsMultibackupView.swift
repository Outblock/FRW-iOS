//
//  WhatIsMultibackupView.swift
//  FRW
//
//  Created by cat on 2024/9/14.
//

import SwiftUI

struct WhatIsMultibackupView: RouteableView {
    
    var confirmClosure: EmptyClosure
    
    var title: String {
        return ""
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("What is a".localized)
                    .font(.Montserrat(size: 32, weight: .semibold))
                    .fontWeight(.heavy)
                    .foregroundStyle(Color.Theme.Text.black)
                Text("multi_backup".localized)
                    .font(.Montserrat(size: 32, weight: .semibold))
                    .fontWeight(.heavy)
                    .foregroundStyle(Color.Theme.Accent.green)
            }
            ScrollView {
                Text("multi_backup_detail".localized)
                    .font(.inter(size: 14))
                    .foregroundStyle(Color.Theme.Text.black8)
            }
            
            Spacer()
            
            VPrimaryButton(model: ButtonStyle.primary,
                           state: .enabled,
                           action: {
                              onClick()
            }, title: "ok".localized)
        }
        .padding(.horizontal, 28)
        .applyRouteable(self)
    }
    
    func onClick() {
        confirmClosure()
    }
}

#Preview {
    WhatIsMultibackupView() {
        
    }
}
