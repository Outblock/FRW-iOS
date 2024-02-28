//
//  MoveTokenView.swift
//  FRW
//
//  Created by cat on 2024/2/27.
//

import SwiftUI

struct MoveTokenView: RouteableView {
    @StateObject var viewModel = MoveTokenViewModel()
    
    var title: String {
        ""
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Move Token")
                    .font(.inter(size: 18, weight: .w700))
                    .foregroundStyle(Color.LL.Neutrals.text)
                
                Spacer()
                
                Button {
                    Router.dismiss()
                } label: {
                    Image("icon_close_circle_gray")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            
            Color.clear
                .frame(height: 20)
            
            ZStack {
                VStack(spacing: 8) {
                    MoveUserView()
                    MoveUserView()
                }
                
                Image("icon_move_exchange")
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            
            MoveTokenView.AccountView { _ in
            }
            
            Button {} label: {
                ZStack {
                    Text("move".localized)
                        .foregroundColor(Color.LL.Button.text)
                        .font(.inter(size: 14, weight: .bold))
                }
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .background(Color.LL.Button.color)
                .cornerRadius(16)
            }
            .disabled(!viewModel.isReadyForSend)
        }
        .padding(.horizontal, 18)
        .applyRouteable(self)
    }
}

// MARK: - MoveUserView

struct MoveUserView: View {
    var body: some View {
        HStack {
            Text("From")
                .font(.inter(size: 16, weight: .w600))
                .foregroundStyle(Color.Theme.Text.black3)
                .visibility(.visible)
            
            HStack {
                Image("flow")
                    .resizable()
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("My Wallet")
                            .foregroundColor(Color.LL.Neutrals.text)
                            .font(.inter(size: 14, weight: .semibold))
                        
                        Text("EVM")
                            .font(.inter(size: 9))
                            .foregroundStyle(Color.Theme.Text.white9)
                            .frame(width: 36, height: 16)
                            .background(Color.Theme.Accent.blue)
                            .cornerRadius(8)
//                            .visibility(childAccount.isEvm ? .visible : .gone)
                    }
                    .frame(alignment: .leading)
                    
                    Text("address")
                        .foregroundColor(Color.Theme.Text.black3)
                        .font(.inter(size: 12))
                }
                .frame(alignment: .leading)
            }
            
            Spacer()
            Image("icon_arrow_bottom_16")
                .resizable()
                .frame(width: 16, height: 16)
        }
        .frame(height: 74)
        .padding(.horizontal, 16)
        .background(Color.LL.Neutrals.background)
        .cornerRadius(16)
    }
}

// MARK: - MoveTokenView

extension MoveTokenView {
    struct AccountView: View {
        @State var inputText: String = ""
        @FocusState private var isAmountFocused: Bool
        var textDidChanged: (String) -> Void
        
        var body: some View {
            VStack(spacing: 12) {
                HStack {
                    TextField("", text: $inputText)
                        .keyboardType(.decimalPad)
                        .disableAutocorrection(true)
                        .modifier(PlaceholderStyle(showPlaceHolder: inputText.isEmpty,
                                                   placeholder: "0.00",
                                                   font: .inter(size: 30, weight: .w700),
                                                   color: Color.Theme.Text.black3))
                        .font(.inter(size: 30, weight: .w700))
                        .onChange(of: inputText) { text in
                            withAnimation {
                                textDidChanged(text)
//                                vm.inputTextDidChangeAction(text: text)
                            }
                        }
                        .focused($isAmountFocused)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .frame(width: 32, height: 32)
                        Text("Select")
                            .font(.inter(size: 14, weight: .w500))
                        Image("icon_arrow_bottom_16")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    .padding(8)
                    .background(Color.Theme.Line.line)
                    .cornerRadius(16)
                }
                
                HStack {
                    Text("$ 0.00")
                        .font(.inter(size: 16))
                        .foregroundStyle(Color.LL.Neutrals.text2)
                    
                    Spacer()
                    
                    Button {} label: {
                        Text("max".localized)
                            .font(.inter(size: 12, weight: .w500))
                            .foregroundStyle(Color.Theme.Accent.grey)
                            .padding(.horizontal, 5)
                            .frame(height: 24)
                            .background(Color.Theme.Accent.grey.fixedOpacity())
                            .cornerRadius(16)
                    }
                }
            }
            .background(Color.Theme.Background.white)
            .padding(20)
        }
    }
}

#Preview {
    MoveTokenView()
//    MoveTokenView.AccountView { _ in
//    }
}
