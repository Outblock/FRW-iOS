//
//  MultiBackupPhraseView.swift
//  FRW
//
//  Created by cat on 2024/1/8.
//

import SwiftUI

struct MultiBackupPhraseView: RouteableView {
    
    @State var isBlur: Bool = true
    var mnemonic: String
    private var dataSource: [WordListView.WordItem]
    init(mnemonic: String) {
        self.mnemonic = mnemonic
        self.dataSource = mnemonic.split(separator: " ").enumerated().map { item in
            WordListView.WordItem(id: item.offset + 1, word: String(item.element))
        }
    }
    
    var title: String {
        return ""
    }
    
    var copyBtn: some View {
        Button {
            UIPasteboard.general.string = self.mnemonic
            HUD.success(title: "copied".localized)
        } label: {
            Image("icon-copy-phrase")
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("recovery".localized)
                            .bold()
                            .foregroundColor(Color.LL.text)

                        Text("phrase".localized)
                            .bold()
                            .foregroundColor(Color.LL.orange)
                    }
                    .font(.LL.largeTitle)

                    Text("words_save_tips".localized)
                        .font(.LL.body)
                        .foregroundColor(.LL.note)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()

                VStack {
                    HStack {
                        Spacer()
                        WordListView(data: Array(dataSource.prefix(6)))
                        Spacer()
                        WordListView(data: Array(dataSource.suffix(from: 6)))
                        Spacer()
                    }

                    Text("hide".localized)
                        .padding(5)
                        .padding(.horizontal, 5)
                        .foregroundColor(.LL.background)
                        .font(.LL.body)
                        .background(.LL.note)
                        .cornerRadius(12)
                        .onTapGesture {
                            isBlur = true
                        }
                }
                .onTapGesture {
                    isBlur.toggle()
                }
                .blur(radius: isBlur ? 10 : 0)
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .overlay {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(lineWidth: 0.5)
                        VStack(spacing: 10) {
                            Image(systemName: "eyes")
                                .font(.largeTitle)
                            Text("private_place_tips".localized)
                                .foregroundColor(.LL.note)
                                .font(.LL.body)
                                .fontWeight(.semibold)
                            Text("reveal".localized)
                                .padding(5)
                                .padding(.horizontal, 2)
                                .foregroundColor(.LL.background)
                                .font(.LL.body)
                                .background(.LL.note)
                                .cornerRadius(12)
                                .padding(.top, 10)
                        }
                        .opacity(isBlur ? 1 : 0)
                        .foregroundColor(.LL.note)
                    }
                    .allowsHitTesting(false)
                }
                .animation(.linear(duration: 0.2), value: isBlur)
                .padding(.top, 20)
                
                VStack(alignment: .leading) {
                    copyBtn
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 10) {
                    Text("not_share_secret_tips".localized)
                        .font(.LL.caption)
                        .bold()
                    Text("not_share_secret_desc".localized)
                        .font(.LL.footnote)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                .foregroundColor(.LL.warning2)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.LL.warning6)
                }
                .padding(.top)
                .padding(.bottom)
            }
        }
        .padding(.horizontal, 28)
        .backgroundFill(Color.LL.background)
        .applyRouteable(self)
    }
}



#Preview {
    MultiBackupPhraseView(mnemonic: "ab ce ef df dd fe sdf efs ee adf adf cv")
}
