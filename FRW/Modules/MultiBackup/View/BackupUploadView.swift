//
//  BackupUploadView.swift
//  FRW
//
//  Created by cat on 2023/12/14.
//

import SwiftUI

struct BackupUploadView: RouteableView {
    @StateObject var viewModel: BackupUploadViewModel = .init()
    
    var title: String {
        return "multi_backup".localized
    }
    
    var body: some View {
        VStack {
            BackupUploadView.ProgressView(items: viewModel.items,
                                          currentIndex: $viewModel.currentIndex
            )
            .padding(.horizontal, 56)
            
            VStack(spacing: 24) {
                Image(viewModel.currentIcon)
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: 120, height: 120)
                  .background(.Theme.Background.white)
                  .cornerRadius(60)
                  .clipped()
                
                Text(viewModel.currentTitle)
                    .font(.inter(size: 20, weight: .bold))
                    .foregroundStyle(Color.Theme.Text.black)

                Text(viewModel.currentNote)
                  .font(.inter(size: 12))
                  .multilineTextAlignment(.center)
                  .foregroundColor(.Theme.Accent.grey)
                  .frame(alignment: .top)
            }
            .padding(.horizontal, 40)
            
            BackupUploadTimeline(backupType: viewModel.currentType, isError: viewModel.hasError, process: viewModel.process)
            
            Spacer()
            
            VPrimaryButton(model: ButtonStyle.primary,
                           state: .enabled,
                           action: {
                
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
        let items: [BackupType]
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
        let itemType: BackupType
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

#Preview {
    BackupUploadView()
}
