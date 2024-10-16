//
//  ChildAccountSideCell.swift
//  FRW
//
//  Created by cat on 2024/3/19.
//

import Kingfisher
import SwiftUI
import SwiftUIX

protocol ChildAccountSideCellItem {
    var showAddress: String { get }
    var showIcon: String { get }
    var showName: String { get }
    var isEVM: Bool { get }
    var isSelected: Bool { get }
}

struct ChildAccountSideCell: View {
    var item: ChildAccountSideCellItem
    var isSelected: Bool = false
    var onClick: (String) -> Void

    var body: some View {
        Button {
            onClick(item.showAddress)
        } label: {
            HStack(spacing: 15) {
                KFImage.url(URL(string: item.showIcon))
                    .placeholder {
                        Image("placeholder")
                            .resizable()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24)
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("\(item.showName)")
                            .foregroundColor(Color.LL.Neutrals.text)
                            .font(.inter(size: 14, weight: .semibold))

                        Text("EVM")
                            .font(.inter(size: 9))
                            .foregroundStyle(Color.Theme.Text.white9)
                            .frame(width: 36, height: 16)
                            .background(Color.Theme.Accent.blue)
                            .cornerRadius(8)
                            .visibility(item.isEVM ? .visible : .gone)
                    }
                    .frame(alignment: .leading)

                    Text(item.showAddress)
                        .foregroundColor(Color.LL.Neutrals.text3)
                        .font(.inter(size: 12))
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .frame(alignment: .leading)

                Spacer()

                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(Color(hex: "#00FF38"))
                    .visibility(item.isSelected ? .visible : .gone)
            }
            .frame(height: 66)
            .padding(.leading, 18)
            .padding(.trailing, 18)
            .background {
                selectedBg
                    .visibility(item.isSelected ? .visible : .gone)
            }
            .contentShape(Rectangle())
        }
    }

    var selectedBg: some View {
        LinearGradient(colors: [Color(hex: "#00FF38").opacity(0.08), Color(hex: "#00FF38").opacity(0)], startPoint: .leading, endPoint: .trailing)
    }
}
