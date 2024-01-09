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
        VStack {
            BackupUploadView.ProgressView(items: viewModel.items,
                                          currentIndex: $viewModel.currentIndex)
                .padding(.top, 24)
                .padding(.horizontal, 56)
            
            VStack(spacing: 24) {
                Image(viewModel.currentIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .background(.Theme.Background.white)
                    .cornerRadius(60)
                    .clipped()
                    .visibility(viewModel.process != .end ? .visible : .gone)
                
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
            }
            .padding(.top, 32)
            .padding(.horizontal, 40)
            
            BackupUploadTimeline(backupType: viewModel.currentType, isError: viewModel.hasError, process: viewModel.process)
                .padding(.top, 64)
                .visibility(viewModel.showTimeline() ? .visible : .gone)
            
            Spacer()
            
            VPrimaryButton(model: ButtonStyle.primary,
                           state: .enabled,
                           action: {
                               viewModel.onClickButton()
                           }, title: viewModel.currentButton)
                .padding(.horizontal, 18)
                .padding(.bottom)
        }
        .applyRouteable(self)
        .backgroundFill(Color.LL.Neutrals.background)
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
                }else if items.count == 2 {
                    twoBuild()
                }else {
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
                    .offset(y:-12)
                    .rotationEffect( items.count > 3 ? Angle.init(degrees: 30) : .zero)
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

#Preview {
//    BackupUploadView(items: [])
    BackupUploadView.CompletedView(items: [.google,.passkey, .icloud, ])
}
