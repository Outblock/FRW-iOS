//
//  NotificationView.swift
//  FRW
//
//  Created by cat on 2024/6/27.
//

import SwiftUI
import Kingfisher

struct WalletNotificationView: View {
    let data: NotificationData
    var onClose: () -> Void
    var onAction: () -> Void
        
    var body: some View {
        HStack(spacing: 12) {
            if !data.icon.isEmpty {
                KFImage.url(URL(string: data.icon))
                    .placeholder({
                        Image("placeholder")
                            .resizable()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24)
                    .cornerRadius(12)
                    .clipped()
                    .allowsHitTesting(false)
            }
            
                
            VStack(alignment: .leading, spacing: 0) {
                Text(data.title)
                    .font(.inter(size: 16, weight: .semibold))
                    .foregroundStyle(Color.Theme.Text.black)
                    .frame(height: 24)
                    .allowsHitTesting(false)
                    
                if data.linkUrl.isEmpty {
                    Text(data.actionText)
                        .font(.inter(size: 14))
                        .foregroundStyle(Color.Theme.Text.black8)
                        .allowsHitTesting(false)
                }else {
                    Button(action: onAction) {
                        Text(data.actionText)
                            .font(.inter(size: 14))
                            .underline()
                            .foregroundStyle(Color.Theme.Text.black8)
                    }
                }
                
            }
                
            Spacer()
            VStack {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 72)
        .background(Color.Theme.Background.grey.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: Color(red: 0.2, green: 0.2, blue: 0.2).opacity(0.32), radius: 2, x: 0, y: 4)
    }
}

struct NotificationData: Identifiable,Equatable,Hashable {
    let id = UUID()
    let icon: String
    let title: String
    let actionText: String
    let iconBackgroundColor: Color
    let linkUrl: String
    
    static let sample = NotificationData(
        icon: "bell.fill",
        title: "Pending request from flow port",
        actionText: "View More",
        iconBackgroundColor: .blue,
        linkUrl: "http"
    )
}

struct WalletNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        WalletNotificationView(
            data: .sample,
            onClose: {},
            onAction: {}
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
