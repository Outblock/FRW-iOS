//
//  CreatePinCode.swift
//  Flow Reference Wallet
//
//  Created by Hao Fu on 6/1/22.
//

import Combine
import SwiftUI
import SwiftUIX

extension CreatePinCodeView {
    struct ViewState {}

    enum Action {
        case input(String)
    }
}

struct CreatePinCodeView: RouteableView {
    @StateObject var viewModel = CreatePinCodeViewModel()
    @State var text: String = ""
    @State var focuse: Bool = false
    @FocusState private var pinCodeViewIsFocus: Bool
    
    var title: String {
        return ""
    }

    var body: some View {
        VStack(spacing: 15) {
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    Text("create_a".localized)
                        .bold()
                        .foregroundColor(Color.LL.text)

                    Text("pin".localized)
                        .bold()
                        .foregroundColor(Color.LL.orange)
                }
                .font(.LL.largeTitle)

                Text("no_one_unlock_desc".localized)
                    .font(.LL.body)
                    .foregroundColor(.LL.note)
                    .padding(.top, 1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 30)
            
            PinCodeTextField(text: $text)
                .keyboardType(.numberPad)
                .fixedSize()
                .focused($pinCodeViewIsFocus)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        pinCodeViewIsFocus = true
                    }
                }
                .onChange(of: text) { value in
                    viewModel.trigger(.input(value))
                }

            Spacer()
        }
        .padding(.horizontal, 28)
        .backgroundFill(.LL.background)
        .applyRouteable(self)
    }
}

struct CreatePinCodeView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePinCodeView()
    }
}
