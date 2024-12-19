//
//  BackupMultiView.swift
//  FRW
//
//  Created by cat on 2023/12/7.
//

import SwiftUI
import SwiftUIX

// MARK: - BackupMultiView

struct BackupMultiView: RouteableView {
    // MARK: Lifecycle

    init(items: [MultiBackupType]) {
        _viewModel = StateObject(wrappedValue: BackupMultiViewModel(backups: items))
    }

    // MARK: Internal

    @StateObject
    var viewModel: BackupMultiViewModel

    var title: String {
        "multi_backup".localized
    }

    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Text("multi_backup_guide_title".localized)
                    .font(.inter(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.Theme.Accent.grey)
            }
            .padding(.horizontal, 40)

            VStack(spacing: 8) {
                ForEach(viewModel.list.indices, id: \.self) { index in
                    let item = $viewModel.list[index]
                    ItemView(item: item) { item in
                        onClick(item: item)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 24)

            Spacer()

            VStack(alignment: .center) {
                VStack(alignment: .center) {
                    Text("what_is_multi".localized)
                        .font(.inter(size: 16, weight: .bold))
                        .foregroundStyle(Color.Theme.Accent.grey)
                        .frame(height: 18)
                    Text("what_is_multi_short".localized)
                        .font(.inter(size: 14))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.Theme.Accent.grey)
                }
                .padding(.horizontal, 28)

                Button(action: {
                    onLearnMore()
                }, label: {
                    Text("Learn__more::message".localized)
                        .font(.inter(size: 14, weight: .semibold))
                        .foregroundStyle(Color.Theme.Accent.blue)

                })
                .frame(height: 50)
            }

            Spacer()

            VPrimaryButton(
                model: ButtonStyle.primary,
                state: viewModel.nextable ? .enabled : .disabled,
                action: {
                    onNext()
                },
                title: "next".localized
            )
            .padding(.horizontal, 18)
            .padding(.bottom)
        }
        .applyRouteable(self)
        .backgroundFill(Color.LL.Neutrals.background)
    }

    func columns() -> [GridItem] {
        let width = (screenWidth - 64 * 2) / 2
        return [
            GridItem(.adaptive(minimum: width)),
            GridItem(.adaptive(minimum: width)),
        ]
    }

    func onClick(item: BackupMultiViewModel.MultiItem) {
        viewModel.onClick(item: item)
    }

    func onNext() {
        viewModel.onNext()
    }

    func onLearnMore() {
        viewModel.onLearnMore()
    }
}

// MARK: BackupMultiView.ItemView

extension BackupMultiView {
    struct ItemView: View {
        // MARK: Lifecycle

        init(
            item: Binding<BackupMultiViewModel.MultiItem>,
            onClick: @escaping (BackupMultiViewModel.MultiItem) -> Void
        ) {
            _item = item
            self.onClick = onClick
            _isSelected = item.isBackup
        }

        // MARK: Internal

        @Binding
        var item: BackupMultiViewModel.MultiItem
        var onClick: (BackupMultiViewModel.MultiItem) -> Void

        var body: some View {

            HStack(spacing: 12) {
                Image(item.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                    .clipped()

                Text(item.name)
                    .font(.inter(size: 14))
                    .foregroundStyle(Color.Theme.Text.black8)

                Spacer()
                Image("check_circle_border")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .visibility(isSelected ? .visible : .gone)
            }
            .padding(.horizontal, 16)
            .frame(height: 68)
            .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .inset(by: 0.5)
                    .stroke(Color.Theme.Accent.green, lineWidth: isSelected ? 1 : 0)
            )
            .frame(maxWidth: .infinity)
            .background(.Theme.Background.pureWhite)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onTapGesture {
                onClick(item)
            }
        }

        @Binding
        private var isSelected: Bool
    }
}

#Preview {
    BackupMultiView(items: [])
}
