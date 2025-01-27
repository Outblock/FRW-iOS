//
//  AccountCell.swift
//  FRW
//
//  Created by Marty Ulrich on 1/24/25.
//

import SwiftUI
import Kingfisher
import Theme

extension AccountCell {
	struct Item {
		var user: WalletAccount.User
		var address: String
		var balance: String
		var isEvm: Bool
	}
}

struct AccountCell: View {
	let item: AccountCell.Item
	
	var body: some View {
		HStack(spacing: 12) {
			item.user.emoji.icon(size: 40)
			VStack(alignment: .leading) {
				HStack(spacing: 0) {
					Text(item.user.name)
						.font(.inter(weight: .semibold))
						.foregroundStyle(Color.Theme.Text.black)
					Text("(\(item.address))")
						.font(.inter(size: 14))
						.lineLimit(1)
						.truncationMode(.middle)
						.foregroundStyle(Color.Theme.Text.black3)
						.frame(maxWidth: 120)
					EVMTagView()
						.visibility(item.isEvm ? .visible : .gone)
						.padding(.leading, 8)
				}
				Text("\(item.balance)")
					.font(.inter(size: 14))
					.foregroundStyle(Color.Theme.Text.black3)
			}
			Spacer()
			Image("icon_arrow_right_28")
				.resizable()
				.renderingMode(.template)
				.aspectRatio(contentMode: .fit)
				.foregroundColor(.Theme.Background.icon)
				.frame(width: 23, height: 24)
		}
		.padding(16)
		.background(.Theme.BG.bg2)
		.cornerRadius(16)
	}
}

#Preview {
	AccountCell(item: AccountCell.Item(
			user: WalletAccount.User(emoji: .avocado, address: "0x9209320920932093203903"),
			address: "0x9209320920932093203903",
			balance: "$200.00",
			isEvm: true
		)
	)
}
