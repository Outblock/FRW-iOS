//
//  MoveNFTsView.swift
//  FRW
//
//  Created by cat on 2024/5/17.
//

import SwiftUI
import Kingfisher

struct MoveNFTsView:  RouteableView {
    var title: String {
        return ""
    }
    
    var isNavigationBarHidden: Bool {
        return true
    }
    
    @StateObject var viewModel = MoveNFTsViewModel()
    
    private let columns = [
            GridItem(.adaptive(minimum: 110), spacing: 4)
        ]
    
    var body: some View {
        VStack(spacing: 0) {
            TitleWithClosedView(title: "select_nfts".localized) {
                viewModel.closeAction()
            }
            
            accountView()
            
            Divider()
                .frame(height: 1)
                .foregroundStyle(Color.Theme.Line.line)
                .padding(.vertical, 24)
            
            NFTListView()
            
            Button {
                viewModel.moveAction()
            } label: {
                Text(viewModel.moveButtonTitle)
                    .font(.inter(size: 16))
                    .foregroundStyle(Color.Theme.Text.black8)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(Color.Theme.Accent.green)
                    .cornerRadius(16)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 18)
        .applyRouteable(self)
        .mockPlaceholder(viewModel.isMock)
    }
    
    @ViewBuilder
    func accountView() -> some View {
        VStack {
            HStack {
                titleView(title: "account".localized)
                Spacer()
            }
            HStack(spacing: 4) {
                accountInfo(isFirst: true)
                    .frame(maxWidth: .infinity)
                Image("evm_move_arrow_right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                accountInfo(isFirst: false)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    func titleView(title: String) -> some View {
        Text(title)
            .font(.inter(size: 16))
            .foregroundStyle(Color.Theme.Text.black8)
    }
    
    @ViewBuilder
    func accountInfo(isFirst: Bool) -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                viewModel.accountIcon(isFirst: isFirst)
                    .padding(.trailing, 4)
                Text(viewModel.accountName(isFirst: isFirst))
                    .font(.inter(size: 14))
                    .foregroundStyle(Color.Theme.Text.black)
                    .padding(.trailing, 8)
                EVMTagView()
                    .visibility(viewModel.showEVMTag(isFirst: isFirst) ? .visible : .gone)
                Spacer()
            }
            
            Text(viewModel.accountAddress(isFirst: isFirst))
                .font(.inter(size: 12))
                .lineLimit(1)
                .truncationMode(.middle)
                .foregroundStyle(Color.Theme.Text.black8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.Theme.Background.silver)
        .cornerRadius(12)
    }
    
    @ViewBuilder
    func NFTListView() -> some View {
        
        VStack(spacing: 0) {
            HStack {
                titleView(title: "collection".localized)
                Spacer()
                if let info = viewModel.selectedCollection {
                    Button {
                        viewModel.selectCollectionAction()
                    } label: {
                        HStack {
                            KFImage.url(info.collection.logoURL)
                                .placeholder({
                                    Image("placeholder")
                                        .resizable()
                                })
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 24, height: 24)
                                .cornerRadius(8)
                                .clipped()
                                .padding(.trailing,8)
                            
                            Text(info.collection.name)
                                .font(.inter(size: 14))
                                .foregroundStyle(Color.Theme.Text.black)
                                .padding(.trailing, 4)
                            
                            viewModel.logo()
                                .resizable()
                                .frame(width: 12, height: 12)
                            
                           Image("icon-arrow-bottom")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                        }
                    }
                }

            }
            .padding(.bottom, 8)
            
            if viewModel.nfts.count == 0 {
                HStack {
                    Spacer()
                    Text("0 NFTs")
                        .font(.inter(size: 16))
                        .foregroundStyle(Color.Theme.Text.black3)
                    Spacer()
                }
                .padding(.top, 24)
            }
            
            ScrollView {
                LazyVGrid(columns: columns,spacing: 4){
                    ForEach(viewModel.nfts) { nft in
                        NFTView(nft: nft)
                            .onTapGesture {
                                viewModel.toggleSelection(of: nft)
                            }
                    }
                }
                
                Spacer()
            }
            .overlay(alignment: .bottom) {
                hintView
                    .visibility(viewModel.showHint ? .visible : .gone)
            }
        }
    }
    
    var hintView: some View {
        HStack(spacing: 4) {
            Image("icon_move_waring")
                .resizable()
                .frame(width: 20, height: 20)
            Text("move_nft_limit_x".localized(String(viewModel.limitCount)))
                .font(.inter(size: 14))
                .foregroundStyle(Color.Theme.Text.black)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.Theme.Accent.orange)
        .cornerRadius(24)
        .offset(y: -8)
    }
}

extension MoveNFTsView {
    struct NFTView: View {
        var nft: MoveNFTsViewModel.NFT
        
        var body: some View {
            VStack {
                KFImage.url(URL(string: nft.imageUrl))
                    .placeholder({
                        Image("placeholder")
                            .resizable()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .topTrailing){
                RoundedRectangle(cornerRadius: 16)
                  .inset(by: 0.5)
                  .stroke(Color.Theme.Accent.green, lineWidth: 1)
                  .background(Color.black.opacity(0.6))
                  .visibility(nft.isSelected ? .visible : .gone)
            }
            .overlay(alignment: .topTrailing, content: {
                Image(nft.isSelected ? "evm_check_1" : "evm_check_0")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .padding([.top,.trailing],8)
            })
            
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    MoveNFTsView()
}
