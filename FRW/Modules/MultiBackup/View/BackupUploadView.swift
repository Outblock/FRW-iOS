//
//  BackupUploadView.swift
//  FRW
//
//  Created by cat on 2023/12/14.
//

import SwiftUI

struct BackupUploadView: RouteableView {
    @StateObject var viewModel: BackupUploadViewModel

    init(items: [MultiBackupType]) {
        _viewModel = StateObject(wrappedValue: BackupUploadViewModel(items: items))
    }

    var title: String {
        return "multi_backup".localized
    }

    var body: some View {
        VStack(alignment: .center) {
            BackupUploadView.ProgressView(items: viewModel.items,
                                          currentIndex: $viewModel.currentIndex)
                .padding(.top, 24)
                .padding(.horizontal, 56)
                .visibility(viewModel.process == .end ? .gone : .visible)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    if viewModel.process != .end {
                        Image(viewModel.currentIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .background(.Theme.Background.white)
                            .cornerRadius(60)
                            .clipped()
                            .visibility((viewModel.currentType == .phrase && viewModel.process != .idle) ? .gone : .visible)
                    }

                    BackupUploadView.CompletedView(items: viewModel.items)
                        .visibility(viewModel.process == .end ? .visible : .gone)

                    Text(viewModel.currentTitle)
                        .font(.inter(size: 20, weight: .bold))
                        .foregroundStyle(Color.Theme.Text.black)

                    Text(viewModel.currentNote)
                        .font(.inter(size: 12))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.Theme.Accent.grey)
                        .frame(alignment: .top)
                        .visibility(viewModel.process == .end ? .gone : .visible)
                }
                .padding(.top, 32)
                .padding(.horizontal, 40)

                if viewModel.currentType != .phrase {
                    BackupUploadTimeline(backupType: viewModel.currentType, isError: viewModel.hasError, process: viewModel.process)
                        .padding(.top, 64)
                        .visibility(viewModel.showTimeline() ? .visible : .gone)
                }

                if viewModel.currentType == .phrase {
                    ScrollView(showsIndicators: false, content: {
                        if viewModel.process == .idle {
                            VStack {
                                TextCheckListView(titles: [
                                    "multi_check_phrase_1".localized,
                                    "multi_check_phrase_2".localized,
                                    "multi_check_phrase_3".localized,
                                ], allChecked: $viewModel.checkAllPhrase)

                                Button {
                                    viewModel.learnMore()
                                } label: {
                                    Text("Learn__more::message".localized)
                                        .font(.inter(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.Theme.Accent.blue)
                                        .padding(.vertical, 16)
                                }
                            }
                            .padding(.top, 16)
                        } else if viewModel.process == .regist || viewModel.process == .upload || viewModel.process == .finish {
                            if let mnemonic = MultiBackupManager.shared.mnemonic {
                                BackupUploadView.PhraseWords(isBlur: viewModel.mnemonicBlur, mnemonic: mnemonic)
                                    .padding(.horizontal, 24)
                            }
                        }
                    })
                }

                if viewModel.process == .end {
                    VStack {
                        VStack {
                            ForEach(viewModel.items, id: \.self) { backupType in
                                BackupedItemView(backupType: backupType)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 18)
                    }
                    .padding(.top, 8)
                }
            }
            .clipped()

            Spacer()

            VPrimaryButton(model: ButtonStyle.primary,
                           state: viewModel.buttonState,
                           action: {
                               viewModel.onClickButton()
                           }, title: viewModel.currentButton)
                .padding(.horizontal, 18)
                .padding(.bottom)
        }
        .applyRouteable(self)
        .backgroundFill(Color.LL.Neutrals.background)
    }

    func backButtonAction() {
        Router.popToRoot()
    }
}

extension BackupUploadView {
    struct ProgressView: View {
        let items: [MultiBackupType]
        @Binding var currentIndex: Int
        var body: some View {
            HStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { index in
                    let isSelected = currentIndex >= index
                    BackupUploadView.ProgressItem(itemType: items[index],
                                                  isSelected: isSelected)
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 1)
                        .background(isSelected ? .Theme.Accent.green
                            : .Theme.Background.silver
                        )
                }

                Image(currentIndex >= items.count ? "icon.finish.highlight" : "icon.finish.normal")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
            }
        }
    }

    struct ProgressItem: View {
        let itemType: MultiBackupType
        var isSelected: Bool = false

        var body: some View {
            ZStack {
                Image(isSelected ? itemType.highlightIcon
                    : itemType.normalIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
            }
        }
    }
}

extension BackupUploadView {
    struct CompletedView: View {
        let items: [MultiBackupType]

        var body: some View {
            build()
        }

        func build() -> some View {
            return VStack {
                if items.count == 1 {
                    firstBuild()
                } else if items.count == 2 {
                    twoBuild()
                } else {
                    moreBuild()
                }
            }
        }

        private func firstBuild() -> some View {
            return icon(name: items.first!.iconName())
        }

        private func twoBuild() -> some View {
            return HStack {
                if items.count == 2 {
                    icon(name: items[0].iconName())
                    linkIcon()
                    icon(name: items[1].iconName())
                }
            }
        }

        private func moreBuild() -> some View {
            return VStack(spacing: 0) {
                HStack {
                    if items.count >= 2 {
                        icon(name: items[0].iconName())
                        Spacer()
                        icon(name: items[1].iconName())
                    }
                }
                linkIcon()
                    .offset(y: -12)
                    .rotationEffect(items.count > 3 ? Angle(degrees: 30) : .zero)
                HStack {
                    if items.count >= 3 {
                        icon(name: items[2].iconName())
                    }
                    if items.count >= 4 {
                        Spacer()
                        icon(name: items[3].iconName())
                    }
                }
                .padding(.top, 16)
            }
        }

        private func icon(name: String) -> some View {
            return Image(name)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .background(.Theme.Background.white)
                .cornerRadius(40)
                .clipped()
        }

        private func linkIcon() -> some View {
            return Image("icon.backup.link")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 24, height: 24)
                .cornerRadius(12)
                .clipped()
        }
    }
}

extension BackupUploadView {
    struct PhraseWords: View {
        var isBlur: Bool = true
        private var dataSource: [WordListView.WordItem]
        var mnemonic: String

        init(isBlur: Bool, mnemonic: String) {
            self.mnemonic = mnemonic
            self.isBlur = isBlur
            dataSource = mnemonic.split(separator: " ").enumerated().map { item in
                WordListView.WordItem(id: item.offset + 1, word: String(item.element))
            }
        }

        var body: some View {
            VStack {
                VStack {
                    HStack {
                        Spacer()
                        WordListView(data: Array(dataSource.prefix(8)))
                        Spacer()
                        WordListView(data: Array(dataSource.suffix(from: 8)))
                        Spacer()
                    }
                }
                .blur(radius: isBlur ? 10 : 0)
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .border(Color.Theme.Text.black, cornerRadius: 16)
                .animation(.linear(duration: 0.2), value: isBlur)
                .padding(.top, 20)

                VStack(alignment: .leading) {
                    Button {
                        UIPasteboard.general.string = self.mnemonic
                        HUD.success(title: "copied".localized)
                    } label: {
                        Image("icon-copy-phrase")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(Color.Theme.Accent.green)
                            .frame(width: 100, height: 40)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .visibility(isBlur ? .gone : .visible)

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
                .visibility(isBlur ? .gone : .visible)
            }
        }
    }
}

extension BackupUploadView {
    struct AllBackupView: View {
        var body: some View {
            VStack {}
        }
    }
}

#Preview {
//    BackupUploadView(items: [])
//    BackupUploadView.CompletedView(items: [.google,.passkey, .icloud, ])
    BackupUploadView.PhraseWords(isBlur: true, mnemonic: "timber bulk peace tree cannon vault tomorrow case violin decade bread song song song song")
}
