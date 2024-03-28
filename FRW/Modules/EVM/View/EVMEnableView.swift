//
//  EVMEnableView.swift
//  FRW
//
//  Created by cat on 2024/2/26.
//

import SwiftUI

struct EVMEnableView: RouteableView {
    @StateObject var viewModel = EVMEnableViewModel()
    
    var title: String {
        return ""
    }
    
    var isNavigationBarHidden: Bool {
        return true
    }
    
    var body: some View {
        return VStack {
            HStack {
                Spacer()
                Button {
                    viewModel.onSkip()
                } label: {
                    Text("skip".localized)
                        .font(.inter(size: 14))
                        .foregroundStyle(ThemeManager.shared.style == .light ? Color.Theme.Text.black : Color.Theme.Text.black8)
                        .padding(.horizontal, 16)
                        .frame(height: 32)
                        .background(ThemeManager.shared.style == .light ? Color.Theme.Text.black3 : Color.Theme.Text.black8)
                        .cornerRadius(24)
                }
                .transition(.opacity)
            }
            .padding(.horizontal, 24)
            
            Image("evm_big_planet")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Text("Enable the path")
                .font(.inter(size: 30, weight: .w700))
                .foregroundStyle(Color.Theme.Text.black8)
                .multilineTextAlignment(.center)
            HStack(spacing: 0) {
                Text("to ")
                    .font(.inter(size: 30, weight: .w700))
                    .foregroundStyle(Color.Theme.Text.black8)
                    .multilineTextAlignment(.center)
                Text("FlowEVM")
                    .font(.inter(size: 30, weight: .w700))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#00EF8B"), Color(hex: "#BE9FFF")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            Text("enable_evm_tip".localized)
                .font(.inter(size: 14))
                .foregroundStyle(Color.Theme.Text.black8)
                .multilineTextAlignment(.center)
            Spacer()
            
            Button {
                viewModel.onClickEnable()
            } label: {
                Text("enable".localized)
                    .font(.inter(size: 16, weight: .w600))
                    .foregroundStyle(Color.Theme.Text.white9)
                    .frame(width: 115, height: 48)
                    .background(Color.Theme.Accent.green)
                    .cornerRadius(16)
            }
            
            Button {
                viewModel.onClickLearnMore()
            } label: {
                Text("Learn__more::message".localized)
                    .font(.inter(size: 16))
                    .foregroundStyle(Color.Theme.Text.black8)
            }
            .padding(.top)
            .padding(.bottom)
        }
        .applyRouteable(self)
    }
}

#Preview {
    EVMEnableView()
}
