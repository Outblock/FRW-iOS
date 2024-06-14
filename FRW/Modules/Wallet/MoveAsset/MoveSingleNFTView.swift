//
//  MoveSingleNFTView.swift
//  FRW
//
//  Created by cat on 2024/5/22.
//

import SwiftUI
import SwiftUIX
import Kingfisher

struct MoveSingleNFTView: View {
    @StateObject var viewModel: MoveSingleNFTViewModel
    
    init(nft: NFTModel, callback: @escaping ()->()) {
        _viewModel = StateObject(wrappedValue: MoveSingleNFTViewModel(nft: nft, callback: callback))
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HStack {
                            Text("move_single_nft".localized)
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
                        VStack(spacing: 0) {
                            MoveUserView(user: viewModel.showFromUser,
                                         address: viewModel.showFromAddress,
                                         isEVM: viewModel.fromEVM)
                            .padding(.bottom, 8)
                            MoveUserView(user: viewModel.showToUser,
                                         address: viewModel.showToAddress,
                                         isEVM: !viewModel.fromEVM)
                            HStack {
                                KFImage.url(viewModel.nft.imageURL)
                                    .placeholder({
                                        Image("placeholder")
                                            .resizable()
                                    })
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 64, height: 64)
                                    .cornerRadius(8)
                                    .clipped()
                                    .padding(.trailing,8)
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(viewModel.nft.title)
                                        .font(.inter(size: 16, weight: .bold))
                                        .foregroundColor(.LL.Neutrals.text)
                                        .frame(height: 28)
                                    
                                    HStack(alignment: .center, spacing: 6) {
                                        KFImage
                                            .url(viewModel.nft.logoUrl)
                                            .placeholder {
                                                Image("placeholder")
                                                    .resizable()
                                            }
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 20, height: 20, alignment: .center)
                                            .cornerRadius(20)
                                            .clipped()
                                        Text(viewModel.nft.collectionName)
                                            .font(.LL.body)
                                            .fontWeight(.w400)
                                            .lineLimit(1)
                                            .foregroundColor(.LL.Neutrals.text2)
                                        viewModel.logo()
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.top, 20)
                            .padding(.horizontal, 18)
                            .padding(.bottom, 24)
                            .background(Color.Theme.Line.line)
                            .cornerRadius([.bottomLeading, .bottomTrailing], 16)
                            .padding(.horizontal, 10)
                        }
                        
                        Spacer()
                        
                    }
                    .padding(18)
                    
                }
                
            }
            .hideKeyboardWhenTappedAround()
            .backgroundFill(Color.Theme.Background.grey)
            .cornerRadius([.topLeading, .topTrailing], 16)
            .edgesIgnoringSafeArea(.bottom)
            .overlay(alignment: .bottom) {
                VPrimaryButton(model: ButtonStyle.primary,
                               state: .enabled ,
                               action: {
                    viewModel.moveAction()
                               }, title: "move".localized)
                    .padding(.horizontal, 18)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 8)
            }
        }
        
    }
}

#Preview {
    MoveSingleNFTView(nft: NFTModel(NFTResponse(id: "", name: "", description: "", thumbnail: "", externalURL: "", contractAddress: "", collectionID: "", collectionName: "", collectionDescription: "", collectionSquareImage: "", collectionExternalURL: "", collectionContractName: "", collectionBannerImage: "", traits: [], postMedia: NFTPostMedia(title: "", description: "", video: "", isSvg: false)), in: nil), callback: {})
}
