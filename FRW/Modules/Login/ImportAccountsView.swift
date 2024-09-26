//
//  ImportAccountsView.swift
//  FRW
//
//  Created by cat on 2024/8/19.
//

import SwiftUI
import SwiftUIX
import Flow

class ImportAccountsViewModel: ObservableObject {
    
    var list: [Flow.Account] = []
    var onSelectAddress: (Flow.Account)->()
    
    init(list: [Flow.Account], onSelectAddress: @escaping (Flow.Account) -> ()) {
        self.list = list
        self.onSelectAddress = onSelectAddress
    }
}

struct ImportAccountsView:  RouteableView, PresentActionDelegate {
    
    var title: String {
        return ""
    }
    var changeHeight: (() -> ())?
    
    @StateObject var viewModel: ImportAccountsViewModel
    @State private var selectedAccount: Flow.Account?
    
    init(viewModel: ImportAccountsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                HStack(alignment: .center) {
                    Spacer()
                    Text(headerTitle)
                        .font(.inter(size: 24, weight: .bold))
                        .foregroundStyle(viewModel.list.count == 0 ? Color.Theme.Accent.orange : Color.Theme.Accent.green)
                    Spacer()
                }
                
                Button {
                    onClose()
                } label: {
                    Image("icon_close_circle_gray")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(4)
                        .offset(y: -6)
                }
            }
            .frame(height: 40)
            .padding(.top, 18)
            
            Text("Choose an account you want to import")
                .font(.inter(size: 14))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.Theme.Text.black3)
                .visibility(viewModel.list.count == 0 ? .gone : .visible)
            
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(viewModel.list.indices, id: \.self) { index in
                        let account = viewModel.list[index]
                        let isSelected = (account.address.hex == selectedAccount?.address.hex)
                        ImportAccountsView.Item(account: account, isSelected: isSelected) { itemAccount in
                            self.selectedAccount = itemAccount
                        }
                    }
                }
            }
            .visibility(viewModel.list.count == 0 ? .gone : .visible)
            
            Spacer()
            Text("import_no_account_found".localized)
                .font(.inter(size: 14))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.Theme.Text.black)
                .padding(.horizontal, 27)
                .visibility(viewModel.list.count == 0 ? .visible : .gone)
            
            Spacer()
            
            VPrimaryButton(model: ButtonStyle.primary,
                           state: buttonState(),
                           action: {
                if let account = selectedAccount {
                    onClose()
                    viewModel.onSelectAddress(account)
                }
                
            }, title: buttonTitle())
            .padding(.bottom, 42)
        }
        .padding(.horizontal,18)
        .backgroundFill(Color.Theme.Background.grey)
        .cornerRadius([.topLeading, .topTrailing], 16)
        .applyRouteable(self)
        .ignoresSafeArea()
    }
    
    var headerTitle: String {
        if viewModel.list.count == 0 {
            return "no_account_found".localized
        }
        return "x_account_found_title".localized("\(viewModel.list.count)")
    }
    
    private func buttonState() -> VPrimaryButtonState {
        viewModel.list.count > 0 ? .enabled : .disabled
    }
    
    private func buttonTitle() -> String {
        if selectedAccount == nil {
            return "import_btn_text".localized.uppercasedFirstLetter()
        }
        return "import_x_wallet".localized("1")
    }
    
    func onClose() {
        Router.dismiss()
    }
}

extension ImportAccountsView {
    struct Item: View {
        let account: Flow.Account
        var isSelected: Bool = false
        var onClick: (Flow.Account) -> ()
        
        var body: some View {
            
            HStack {
                Text(account.address.hex)
                    .font(.inter(size: 14, weight: isSelected ? .semibold : .regular))
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .foregroundStyle(Color.Theme.Text.black)
                
                Spacer()
                    
                
                Image(isSelected ? "icon_check_rounde_1" : "icon_check_rounde_0")
                    .resizable()
                    .frame(width: 16, height: 16)
            }
            .padding(.horizontal, 24)
            .frame(height: 56)
            .contentShape(Rectangle())
            .background(isSelected ? Color.Theme.Background.bg3 : .clear )
            .onTapGesture {
                onClick(account)
            }
            .cornerRadius(16)
        }
    }
}

#Preview {
    ImportAccountsView(viewModel: ImportAccountsViewModel(list: [], onSelectAddress: { account in
        
    }))
}
