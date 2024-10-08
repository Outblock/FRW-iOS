//
//  BrowserSignTypedMessageView.swift
//  FRW
//
//  Created by cat on 2024/10/8.
//

import SwiftUI
import Kingfisher

struct BrowserSignTypedMessageView: View {
    
    @StateObject var viewModel: BrowserSignTypedMessageViewModel
    
    init(viewModel: BrowserSignTypedMessageViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        VStack {
            titleView
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(0..<viewModel.sections.count, id: \.self) { index in
                            if index > 0 {
                                Divider()
                                    .foregroundStyle(Color.Theme.Line.line)
                                    .padding(.vertical, 16)
                            }
                            BrowserSignTypedMessageView.Section(section: viewModel.sections[index])
                        }
                    }
                    .padding(16)
                    .background(Color.Theme.Background.bg3)
                    .cornerRadius(16)
                }
            }
            
            Spacer()
            actionView
        }
        .padding(18)
        .background(Color.Theme.Background.bg2)
    }
    
    var titleView: some View {
        HStack(alignment: .top, spacing: 18) {
            HStack {
                KFImage.url(URL(string: viewModel.logo ?? ""))
                    .placeholder {
                        Image("placeholder")
                            .resizable()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 5) {
                    Text("browser_sign_message_request_from".localized)
                        .font(.inter(size: 14))
                        .foregroundColor(Color(hex: "#808080"))

                    Text(viewModel.title)
                        .font(.inter(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 10)

            Button {
                viewModel.onCloseAction()
            } label: {
                Image("close_circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.leading, 10)
                    .padding(.bottom, 10)
            }
        }
    }
    
    var actionView: some View {
        WalletSendButtonView(allowEnable: .constant(true), buttonText: "hold_to_sign".localized) {
            viewModel.didChooseAction(true)
        }
    }
}


extension BrowserSignTypedMessageView {
    
    struct Section: View {
        var section: BrowserSignTypedMessageViewModel.Section
        
        var body: some View {
            VStack {
                HStack {
                    Text(section.showTitle())
                        .font(.inter(size: 14, weight: .semibold))
                        .lineLimit(1)
                        .foregroundStyle(Color.Theme.Text.black8)
                    Spacer()
                    Text(section.content ?? "")
                        .font(.inter(size: 14, weight: .semibold))
                        .lineLimit(1)
                        .foregroundStyle(Color.Theme.Text.black)
                        .frame(minWidth: 0, maxWidth: 120, alignment: .trailing)
                }
                ForEach(section.items, id: \.self.tag) { item in
                    HStack {
                        Text(item.tag.uppercasedFirstLetter())
                            .font(.inter(size: 14, weight: .semibold))
                            .lineLimit(1)
                            .foregroundStyle(Color.Theme.Text.black3)
                        Spacer()
                        Text(item.content)
                            .font(.inter(size: 14, weight: .semibold))
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundStyle(Color.Theme.Text.black)
                            .frame(minWidth: 0, maxWidth: 120, alignment: .trailing)
                            
                    }
                    .frame(height: 20)
                }
            }
        }
    }
}


#Preview {
    BrowserSignTypedMessageView(viewModel: BrowserSignTypedMessageViewModel(title: "ABC", urlString: "http://", rawString: "{\"domain\":{\"name\":\"Ether Mail\",\"version\":\"1\",\"chainId\":747,\"verifyingContract\":\"0xcccccccccccccccccccccccccccccccccccccccc\"},\"message\":{\"from\":{\"name\":\"Cow\",\"wallet\":\"0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826\"},\"to\":{\"name\":\"Bob\",\"wallet\":\"0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\"},\"contents\":\"Hello, Bob!\"},\"primaryType\":\"Mail\",\"types\":{\"EIP712Domain\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"version\",\"type\":\"string\"},{\"name\":\"chainId\",\"type\":\"uint256\"},{\"name\":\"verifyingContract\",\"type\":\"address\"}],\"Person\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"wallet\",\"type\":\"address\"}],\"Mail\":[{\"name\":\"from\",\"type\":\"Person\"},{\"name\":\"to\",\"type\":\"Person\"},{\"name\":\"contents\",\"type\":\"string\"}]}}"))
}
