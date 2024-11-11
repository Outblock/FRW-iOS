//
//  SwapView.swift
//  Flow Wallet
//
//  Created by Selina on 23/9/2022.
//

import Kingfisher
import SwiftUI

// MARK: - SwapView

struct SwapView: RouteableView {
    // MARK: Lifecycle

    init(defaultFromToken: TokenModel? = WalletManager.shared.getToken(bySymbol: "flow")) {
        _vm = StateObject(wrappedValue: SwapViewModel(defaultFromToken: defaultFromToken))
    }

    // MARK: Internal

    enum Field: Hashable {
        case fromToken
        case toToken
    }

    @StateObject
    var vm: SwapViewModel

    var title: String {
        "swap_title".localized
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                VStack(spacing: 12) {
                    fromView
                    toView
                }

                switchButton
                    .padding(.top, 40)
            }

            errorTipsView
                .padding(.top, 12)

            rateView
                .padding(.top, 20)

            Spacer()

            swapBtn
        }
        .padding(.horizontal, 18)
        .padding(.top, 31)
        .frame(maxWidth: .infinity)
        .background(Color.LL.background)
        .applyRouteable(self)
        .halfSheet(showSheet: $vm.showConfirmView, sheetView: {
            SwapConfirmView()
                .environmentObject(vm)
        })
        .onSubmit {
            focusedField = nil
        }
    }

    var errorTipsView: some View {
        HStack {
            Image(systemName: .error)
                .foregroundColor(Color(hex: "#C44536"))

            Text(vm.errorType.desc)
                .foregroundColor(.LL.Neutrals.note)
                .font(.inter(size: 12, weight: .regular))

            Spacer()
        }
        .visibility(vm.errorType == .none ? .gone : .visible)
    }

    var switchButton: some View {
        Button {
            vm.switchTokenAction()
        } label: {
            Image("icon-swap-switch")
        }
        .disabled(vm.fromToken == nil || vm.toToken == nil)
    }

    var swapBtn: some View {
        VPrimaryButton(model: ButtonStyle.primary, state: vm.buttonState, action: {
            focusedField = nil
            vm.swapAction()
        }, title: vm.buttonState == .loading ? "working_on_it".localized : "swap_title".localized)
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
    }

    var rateView: some View {
        Text(vm.rateText)
            .font(.inter(size: 14, weight: .medium))
            .foregroundColor(Color.LL.Neutrals.text2)
            .lineLimit(1)
    }

    // MARK: Private

    @FocusState
    private var focusedField: Field?
}

extension SwapView {
    var fromView: some View {
        VStack(spacing: 0) {
            fromInputContainerView
                .padding(.bottom, 17)

            fromDescContainerView
        }
        .padding(.leading, 21)
        .padding(.trailing, 12)
        .padding(.vertical, 12)
        .background(Color.LL.Neutrals.neutrals6)
        .cornerRadius(16)
    }

    var fromInputContainerView: some View {
        HStack {
            // input view
            TextField("", text: $vm.inputFromText)
                .keyboardType(.decimalPad)
                .disableAutocorrection(true)
                .modifier(PlaceholderStyle(
                    showPlaceHolder: vm.inputFromText.isEmpty,
                    placeholder: "0.00",
                    font: .inter(size: 32, weight: .medium),
                    color: Color.LL.Neutrals.note
                ))
                .font(.inter(size: 32, weight: .medium))
                .foregroundColor(Color.LL.Neutrals.text)
                .onChange(of: vm.inputFromText) { text in
                    withAnimation {
                        vm.inputFromTextDidChangeAction(text: text)
                    }
                }
                .disabled(vm.fromToken == nil)
                .focused($focusedField, equals: .fromToken)

            Spacer()

            fromSelectButton
        }
    }

    var fromSelectButton: some View {
        Button {
            vm.selectTokenAction(isFrom: true)
        } label: {
            HStack(spacing: 0) {
                KFImage.url(vm.fromToken?.iconURL)
                    .placeholder {
                        Image("placeholder-swap-token")
                            .resizable()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())

                Text(vm.fromToken?.symbol?.uppercased() ?? "swap_select".localized)
                    .font(.inter(size: 14, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text2)
                    .padding(.leading, 4)

                Image("icon-arrow-bottom")
                    .renderingMode(.template)
                    .foregroundColor(.LL.Neutrals.text)
                    .padding(.leading, 8)
            }
            .frame(height: 48)
            .padding(.horizontal, 8)
            .background(Color.LL.Neutrals.neutrals4)
            .cornerRadius(16)
        }
    }

    var fromDescContainerView: some View {
        HStack {
            Text("\(CurrencyCache.cache.currencySymbol) \(vm.fromPriceAmountString)")
                .font(.inter(size: 16))
                .foregroundColor(Color.LL.Neutrals.text2)

            Spacer()

            Button {
                vm.maxAction()
            } label: {
                Text("swap_max".localized)
                    .font(.inter(size: 12, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text)
                    .padding(.horizontal, 10)
                    .frame(height: 24)
                    .background(Color.LL.background)
                    .cornerRadius(12)
            }
            .disabled(vm.fromToken == nil)
        }
    }
}

extension SwapView {
    var toView: some View {
        HStack {
            // input view
            TextField("", text: $vm.inputToText)
                .keyboardType(.decimalPad)
                .disableAutocorrection(true)
                .modifier(PlaceholderStyle(
                    showPlaceHolder: vm.inputToText.isEmpty,
                    placeholder: "0.00",
                    font: .inter(size: 32, weight: .medium),
                    color: Color.LL.Neutrals.note
                ))
                .font(.inter(size: 32, weight: .medium))
                .foregroundColor(Color.LL.Neutrals.text)
                .onChange(of: vm.inputToText) { text in
                    withAnimation {
                        vm.inputToTextDidChangeAction(text: text)
                    }
                }
                .disabled(vm.toToken == nil)
                .focused($focusedField, equals: .toToken)

            Spacer()

            toSelectButton
        }
        .padding(.leading, 21)
        .padding(.trailing, 12)
        .padding(.vertical, 12)
        .background(Color.LL.Neutrals.neutrals6)
        .cornerRadius(16)
    }

    var toSelectButton: some View {
        Button {
            vm.selectTokenAction(isFrom: false)
        } label: {
            HStack(spacing: 0) {
                KFImage.url(vm.toToken?.iconURL)
                    .placeholder {
                        Image("placeholder-swap-token")
                            .resizable()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())

                Text(vm.toToken?.symbol?.uppercased() ?? "swap_select".localized)
                    .font(.inter(size: 14, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text2)
                    .padding(.leading, 4)

                Image("icon-arrow-bottom")
                    .renderingMode(.template)
                    .foregroundColor(.LL.Neutrals.text)
                    .padding(.leading, 8)
            }
            .frame(height: 48)
            .padding(.horizontal, 8)
            .roundedBg(
                cornerRadius: 16,
                fillColor: Color.LL.Neutrals.neutrals4,
                strokeColor: Color.LL.Primary.salmonPrimary,
                strokeLineWidth: 1
            )
        }
    }
}
