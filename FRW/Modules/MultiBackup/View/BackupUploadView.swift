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
                    .frame(width: 40, height: 40)
            }
        }
    }
}

#Preview {
    BackupUploadView()
}
