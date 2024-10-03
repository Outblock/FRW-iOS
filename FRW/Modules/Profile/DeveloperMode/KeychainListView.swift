//
//  KeychainListView.swift
//  FRW
//
//  Created by cat on 2024/4/26.
//

import SwiftUI

struct KeychainListView: RouteableView {
    private let viewModel = KeychainListViewModel()
    var title: String {
        return "Keychain"
    }

    var body: some View {
        ScrollView {
            Section {
                ForEach(0 ..< viewModel.localList.count, id: \.self) { index in
                    let item = viewModel.localList[index]
                    itemView(item)
                }
            } header: {
                Text("Local(\(viewModel.localList.count))")
            }
            .visibility(viewModel.localList.count > 0 ? .visible : .gone)

            Section {
                ForEach(0 ..< viewModel.remoteList.count, id: \.self) { index in
                    let item = viewModel.remoteList[index]
                    itemView(item)
                }
            } header: {
                Text("Remote(\(viewModel.remoteList.count))")
            }
            .visibility(viewModel.remoteList.count > 0 ? .visible : .gone)
        }
        .applyRouteable(self)
    }

    func itemView(_ item: [String: Any]) -> some View {
        return HStack {
            VStack(alignment: .leading) {
                Text(viewModel.getKey(item: item))
                    .font(.inter(size: 16))
                    .foregroundStyle(Color.Theme.Accent.red)
                    .lineLimit(2)
                Text(viewModel.mnemonicValue(item: item))
                    .font(.inter(size: 16))
                    .foregroundStyle(Color.Theme.Text.black8)
                    .lineLimit(3)
            }
            Spacer()
            Button {
                UIPasteboard.general.string =
                    viewModel.getKey(item: item) + "\n" +
                    viewModel.mnemonicValue(item: item)
            } label: {
                Image(systemName: "doc.on.doc.fill")
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 80)
        .background(Color.Theme.Background.silver)
    }
}

#Preview {
    KeychainListView()
}
