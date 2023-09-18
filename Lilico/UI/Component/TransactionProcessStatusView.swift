//
//  TransactionProcessStatusView.swift
//  Flow Reference Wallet
//
//  Created by Selina on 30/8/2022.
//

import SwiftUI

struct TransactionProcessStatusView: View {
    private let totalNum: Int = 7
    let status: TransactionManager.InternalStatus
    
    var body: some View {
        VStack(spacing: 7) {
            switch status {
            case .pending:
                pendingView
            case .success:
                successView
            case .failed:
                failedView
            }
            
            textView
        }
    }
    
    var textView: some View {
        Text(text)
            .font(.inter(size: 12, weight: .semibold))
            .foregroundColor(statusMainColor)
            .padding(.horizontal, 12)
            .frame(height: 24)
            .background(textBg)
            .cornerRadius(12)
    }
    
    var pendingView: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalNum, id: \.self) { index in
                switch index {
                case 0:
                    dot.foregroundColor(.LL.Primary.salmon5)
                case 1:
                    dot.foregroundColor(.LL.Primary.salmon4)
                case 2:
                    dot.foregroundColor(.LL.Primary.salmon3)
                case 3:
                    arrow
                default:
                    dot.foregroundColor(.LL.Primary.salmonPrimary)
                }
            }
        }
    }
    
    var successView: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalNum, id: \.self) { index in
                switch index {
                case 0:
                    dot.foregroundColor(.LL.Success.success5)
                case 1:
                    dot.foregroundColor(.LL.Success.success4)
                case 6:
                    arrow
                default:
                    dot.foregroundColor(.LL.Success.success3)
                }
            }
        }
    }
    
    var failedView: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalNum, id: \.self) { index in
                switch index {
                case 0:
                    dot.foregroundColor(.LL.Warning.warning5)
                case 1:
                    dot.foregroundColor(.LL.Warning.warning4)
                case 2:
                    dot.foregroundColor(.LL.Warning.warning3)
                case 4:
                    xmark
                default:
                    dot.foregroundColor(.LL.Warning.warning5)
                }
            }
        }
    }
    
    var xmark: some View {
        Image("icon-red-xmark")
            .renderingMode(.template)
            .foregroundColor(statusMainColor)
    }
    
    var dot: some View {
        Circle()
            .frame(width: 6, height: 6)
    }
    
    var arrow: some View {
        Image("icon-right-arrow-1")
            .renderingMode(.template)
            .foregroundColor(statusMainColor)
    }
    
    var statusMainColor: Color {
        switch status {
        case .pending:
            return Color.LL.Primary.salmonPrimary
        case .success:
            return Color.LL.Success.success3
        case .failed:
            return Color.LL.Warning.warning2
        }
    }
    
    var text: String {
        switch status {
        case .pending:
            return "process_pending_text".localized
        case .success:
            return "process_success_text".localized
        case .failed:
            return "process_failed_text".localized
        }
    }
    
    var textBg: Color {
        switch status {
        case .pending:
            return Color.LL.Primary.salmon5
        case .success:
            return Color.LL.Success.success5
        case .failed:
            return Color.LL.Warning.warning5
        }
    }
}
