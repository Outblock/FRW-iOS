//
//  MultiBackupVerifyPinView.swift
//  FRW
//
//  Created by cat on 2024/2/6.
//

import SwiftUI

struct MultiBackupVerifyPinView: RouteableView {
    @StateObject private var viewModel: MultiBackupVerifyPinViewModel
    @FocusState private var pinCodeViewIsFocus: Bool
    var callback: MultiBackupVerifyPinViewModel.VerifyCallback? = nil
    
    func backButtonAction() {
        Router.dismiss()
        callback?(false, "")
    }
    
    init(from: MultiBackupVerifyPinViewModel.From,
         callback: MultiBackupVerifyPinViewModel.VerifyCallback?)
    {
        self.callback = callback
        _viewModel = StateObject(wrappedValue: MultiBackupVerifyPinViewModel(from: from, callback: callback))
    }
    
    var title: String {
        return " "
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 70) {
                HStack {
                    Text("verify".localized)
                        .bold()
                        .foregroundColor(Color.Theme.Text.black8)

                    Text("pin".localized)
                        .bold()
                        .foregroundColor(Color.Theme.Accent.green)
                }
                .font(.inter(size: 36, weight: .bold))
                
                Text(viewModel.desc)
                    .font(.LL.body)
                    .foregroundColor(.LL.note)
                    .padding(.top, 1)
                
                PinCodeTextField(text: $viewModel.inputPin)
                    .keyboardType(.numberPad)
                    .fixedSize()
                    .modifier(Shake(animatableData: CGFloat(viewModel.pinCodeErrorTimes)))
                    .focused($pinCodeViewIsFocus)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            pinCodeViewIsFocus = true
                        }
                    }
                    .onChange(of: viewModel.inputPin) { value in
                        if value.count == 6 {
                            viewModel.verifyPinAction()
                        }
                    }
            }
            .padding(.bottom, 100)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundFill(Color.LL.Neutrals.background)
        .applyRouteable(self)
    }
}

#Preview {
    MultiBackupVerifyPinView(from: .backup) { _, _ in
    }
}
