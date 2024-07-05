//
//  MoveTokenView.swift
//  FRW
//
//  Created by cat on 2024/2/27.
//

import Kingfisher
import SwiftUI
import SwiftUIX

struct MoveTokenView: RouteableView, PresentActionDelegate {
    var changeHeight: (() -> ())?
    var title: String {
        ""
    }
    
    var isNavigationBarHidden: Bool {
        true
    }
    
    @StateObject var viewModel: MoveTokenViewModel
    
    init(tokenModel: TokenModel, isPresent: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: MoveTokenViewModel(token: tokenModel, isPresent: isPresent))
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HStack {
                            Text("move_single_token".localized)
                                .font(.inter(size: 18, weight: .w700))
                                .foregroundStyle(Color.LL.Neutrals.text)
                                .padding(.top, 6)
                            Spacer()
                            
                            Button {
                                viewModel.closeAction()
                            } label: {
                                Image("icon_close_circle_gray")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding(.top, 8)
                        
                        Color.clear
                            .frame(height: 20)
                        VStack(spacing: 8) {
                            ZStack {
                                VStack(spacing: 8) {
                                    MoveUserView(user: viewModel.showFromUser,
                                                 address: viewModel.showFromAddress,
                                                 isEVM: viewModel.fromEVM)
                                    MoveUserView(user: viewModel.showToUser,
                                                 address: viewModel.showToAddress,
                                                 isEVM: !viewModel.fromEVM)
                                }
                                
                                Image("icon_move_exchange")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                            }
                            
                            MoveTokenView.AccountView { _ in
                            }
                        }
                    }
                    .padding(18)
                }
                Spacer()
                
            }
            .hideKeyboardWhenTappedAround()
            .backgroundFill(Color.Theme.Background.grey)
            .cornerRadius([.topLeading, .topTrailing], 16)
            .environmentObject(viewModel)
            .edgesIgnoringSafeArea(.bottom)
            .overlay(alignment: .bottom) {
                VPrimaryButton(model: ButtonStyle.primary,
                               state: viewModel.buttonState,
                               action: {
                                    log.debug("[Move] click button")
                                    viewModel.onNext()
                                   UIApplication.shared.endEditing()
                               }, title: "move".localized)
                    .padding(.horizontal, 18)
                    .padding(.bottom,  8)
            }
        }
        .applyRouteable(self)
    }
    
    func customViewDidDismiss() {
        MoveAssetsAction.shared.endBrowser()
    }
    
}

// MARK: - MoveUserView

struct MoveUserView: View {
    var user: WalletAccount.User?
    var address: String?
    var isEVM: Bool = false
    var placeholder: String?
    
    var body: some View {
        HStack {
            Text(placeholder ?? "From")
                .font(.inter(size: 16, weight: .w600))
                .foregroundStyle(Color.Theme.Text.black3)
                .visibility(user != nil ? .gone : .visible)
            
            HStack(spacing: 12) {
                user?.emoji.icon(size: 32)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(user?.name ?? "")
                            .foregroundColor(Color.LL.Neutrals.text)
                            .font(.inter(size: 14, weight: .semibold))
                        
                        EVMTagView()
                            .visibility(isEVM ? .visible : .gone)
                    }
                    .frame(alignment: .leading)
                    
                    Text(address ?? "")
                        .foregroundColor(Color.Theme.Text.black3)
                        .font(.inter(size: 12))
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .frame(alignment: .leading)
            }
            .visibility(user == nil ? .gone : .visible)
            
            Spacer()
            Button {} label: {
                Image("icon_arrow_bottom_16")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .visibility(user == nil ? .visible : .gone)
            }
        }
        .frame(height: 56)
        .padding(.horizontal, 16)
        .background(Color.Theme.Background.white)
        .cornerRadius(16)
    }
}

// MARK: - MoveTokenView

extension MoveTokenView {
    struct AccountView: View {
        @EnvironmentObject private var viewModel: MoveTokenViewModel
        
        @FocusState private var isAmountFocused: Bool
        var textDidChanged: (String) -> Void
        
        var body: some View {
            VStack(spacing: 12) {
                HStack {
                    TextField("", text: $viewModel.inputText)
                        .keyboardType(.decimalPad)
                        .disableAutocorrection(true)
                        .modifier(PlaceholderStyle(showPlaceHolder: viewModel.inputText.isEmpty,
                                                   placeholder: "0.00",
                                                   font: .inter(size: 30, weight: .w700),
                                                   color: Color.Theme.Text.black3))
                        .font(.inter(size: 30, weight: .w700))
                        .onChange(of: viewModel.inputText) { text in
                            viewModel.inputTextDidChangeAction(text: text)
                        }
                        .focused($isAmountFocused)
                    
                    switchMenuButton
                    
                }
                
                HStack {
                    Text(viewModel.currentBalance)
                        .font(.inter(size: 16))
                        .foregroundStyle(Color.Theme.Text.black3)
                    
                    Spacer()
                    
                    Button {
                        viewModel.maxAction()
                    } label: {
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
            .padding(16)
            .backgroundFill(Color.Theme.Background.white)
            .cornerRadius(16)
        }
        
        @ViewBuilder
        var switchMenuButton: some View {
            
            Button(action: {
                Router.route(to: RouteMap.Wallet.selectMoveToken(viewModel.token, { selectedToken in
                    viewModel.changeTokenModelAction(token: selectedToken)
                }))
            }, label: {
                HStack(spacing: 4) {
                    KFImage.url(viewModel.token.iconURL)
                        .placeholder({
                            Image("placeholder")
                                .resizable()
                        })
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    Text(viewModel.token.symbol?.uppercased() ?? "?")
                        .font(.inter(size: 14, weight: .medium))
                        .foregroundStyle(Color.LL.Neutrals.text2)
                    Image("icon-arrow-bottom")
                        .foregroundColor(.LL.Neutrals.neutrals3)
                }
                .padding(8)
                .background(Color.Theme.Line.line)
                .cornerRadius(16)
            })
            /*
            Menu {
                ForEach(WalletManager.shared.activatedCoins) { token in
                    Button {
                        viewModel.changeTokenModelAction(token: token)
                    } label: {
                        KFImage.url(token.icon)
                            .placeholder({
                                Image("placeholder")
                                    .resizable()
                            })
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        Text(token.name)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    KFImage.url(viewModel.token.icon)
                        .placeholder({
                            Image("placeholder")
                                .resizable()
                        })
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    Text(viewModel.token.symbol?.uppercased() ?? "?")
                        .font(.inter(size: 14, weight: .medium))
                        .foregroundStyle(Color.LL.Neutrals.text2)
                    Image("icon-arrow-bottom")
                        .foregroundColor(.LL.Neutrals.neutrals3)
                }
                .padding(8)
                .background(Color.Theme.Line.line)
                .cornerRadius(16)
            }
            */
        }
        
    }
    
}

#Preview {
    MoveTokenView(tokenModel: TokenModel(name: "Flow", address: FlowNetworkModel(mainnet: "", testnet: "", crescendo: "", previewnet: ""), contractName: "", storagePath: FlowTokenStoragePath(balance: "100", vault: "a", receiver: ""), decimal: 30, icon: nil, symbol: nil, website: nil, evmAddress: nil, flowIdentifier: nil), isPresent: .constant(true))
//
}
