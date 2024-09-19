//
//  PrivateKeyLoginView.swift
//  FRW
//
//  Created by cat on 2024/8/19.
//

import SwiftUI
import SwiftUIX

struct PrivateKeyLoginView: RouteableView {
    var title: String {
        return "import_wallet".localized
    }
    
    private let backupType: RestoreWalletViewModel.ImportType = .keyStore
    
    @StateObject var viewModel = PrivateKeyLoginViewModel()
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    ImportTitleHeader(backupType: .privateKey)
                        .padding(.top, 48)
                    
                    Section() {
                        
                        ImportTextView(content: $viewModel.key, placeholder: "private_key_placeholder".localized) { value in
                            log.debug("\(value)")
                        }
                        .frame(height: 120)

                    } header: {
                        ImportSectionTitleView(title: "private_key".localized, isStar: true)
                    }
                    
                    Section() {
                        AnimatedSecureTextField(placeholder: "keystore_address".localized, text: $viewModel.address){ text in
                        }
                            .frame(height: 64)
                        
                    } header: {
                        ImportSectionTitleView(title: "address".localized, isStar: false)
                    }
                }
            }
            
            VPrimaryButton(model: ButtonStyle.primary,
                           state: viewModel.buttonState,
                           action: {
                               
            }, title: "import_btn_text".localized)
            .padding(.bottom)
        }
        .padding(.horizontal, 24)
        .backgroundFill(Color.LL.background)
        .applyRouteable(self)
    }
}

#Preview {
    PrivateKeyLoginView()
}
