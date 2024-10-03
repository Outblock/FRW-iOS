//
//  VerifyPinView.swift
//  Flow Wallet
//
//  Created by Selina on 3/8/2022.
//

import SwiftUI

struct VerifyPinView: RouteableView {
    @StateObject private var vm: VerifyPinViewModel
    @FocusState private var pinCodeViewIsFocus: Bool
    var callback: VerifyPinViewModel.VerifyCallback?

    var title: String {
        return ""
    }

    func backButtonAction() {
        Router.dismiss()
        callback?(false)
    }

    init(callback: VerifyPinViewModel.VerifyCallback?) {
        self.callback = callback
        _vm = StateObject(wrappedValue: VerifyPinViewModel(callback: callback))
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 70) {
                Text("verify_x".localized("pin_code".localized))
                    .font(.inter(size: 24, weight: .bold))
                    .foregroundColor(Color.LL.Neutrals.text)
                    .visibility(vm.currentVerifyType == .pin ? .visible : .gone)

                Text("verify_x".localized(SecurityManager.shared.supportedBionic.desc))
                    .font(.inter(size: 24, weight: .bold))
                    .foregroundColor(Color.LL.Neutrals.text)
                    .visibility(vm.currentVerifyType == .bionic ? .visible : .gone)

                PinCodeTextField(text: $vm.inputPin)
                    .keyboardType(.numberPad)
                    .fixedSize()
                    .modifier(Shake(animatableData: CGFloat(vm.pinCodeErrorTimes)))
                    .focused($pinCodeViewIsFocus)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            pinCodeViewIsFocus = true
                        }
                    }
                    .onChange(of: vm.inputPin) { value in
                        if value.count == 6 {
                            vm.verifyPinAction()
                        }
                    }
                    .visibility(vm.currentVerifyType == .pin ? .visible : .gone)

                Button {
                    vm.verifyBionicAction()
                } label: {
                    Image(SecurityManager.shared.supportedBionic == .faceid ? "icon-faceid" : "icon-touchid")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.LL.Primary.salmonPrimary)
                        .frame(width: 70, height: 70)
                }
                .onAppear {
                    vm.verifyBionicAction()
                }
                .visibility(vm.currentVerifyType == .bionic ? .visible : .gone)
            }
            .padding(.bottom, 100)

            Spacer()

            Button {
                vm.changeVerifyTypeAction(type: vm.currentVerifyType == .bionic ? .pin : .bionic)
            } label: {
                Text("switch_to_x".localized(vm.currentVerifyType == .bionic ? "pin_code".localized : SecurityManager.shared.supportedBionic.desc))
                    .font(.inter(size: 16, weight: .medium))
                    .foregroundColor(Color.LL.Primary.salmonPrimary)
            }
            .padding(.bottom, 20)
            .visibility(SecurityManager.shared.securityType == .both ? .visible : .gone)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundFill(Color.LL.Neutrals.background)
    }
}

struct VerifyPinView_Previews: PreviewProvider {
    static var previews: some View {
        VerifyPinView(callback: nil)
    }
}
