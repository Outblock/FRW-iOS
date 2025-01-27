//
//  ConnectingAccountList.swift
//  FRW
//
//  Created by Marty Ulrich on 1/21/25.
//

import SwiftUI

struct Wallet: Identifiable {
	let id = UUID()
	let name: String
	let address: String
	let balanceUSD: Double
	let nftCount: Int
	let nftIconNames: [String]
	let chainTag: String
	let isConnected: Bool
	
	var shortAddress: String {
		// Example: "0x8888...888ab"
		let prefixCount = 6
		let suffixCount = 5
		guard address.count > prefixCount + suffixCount else { return address }
		let start = address.prefix(prefixCount)
		let end = address.suffix(suffixCount)
		return "\(start)...\(end)"
	}
	
	var connectionStatusText: String {
		isConnected ? "Connected" : "Disconnected"
	}
	
	var connectionStatusColor: Color {
		isConnected ? .green : .red
	}
}

struct WalletCellView: View {
	let wallet: Wallet
	
	var body: some View {
		HStack(alignment: .top) {
			// Replace this with an AsyncImage or Image(wallet.name) if you have a real asset name
			Image("coconut-icon")
				.resizable()
				.frame(width: 40, height: 40)
				.clipShape(Circle())
			
			VStack(alignment: .leading, spacing: 8) {
				// Top line: name, short address, chain tag
				HStack(alignment: .firstTextBaseline) {
					Text(wallet.name)
						.font(.headline)
					Text("(\(wallet.shortAddress))")
						.font(.subheadline)
						.foregroundColor(.secondary)
					
					Spacer()
					
					Text(wallet.chainTag)
						.font(.caption)
						.foregroundColor(.white)
						.padding(.horizontal, 6)
						.padding(.vertical, 2)
						.background(Color.blue)
						.clipShape(Capsule())
				}
				
				// Middle line: balance, NFT count, NFT icons
				HStack {
					Text("$\(String(format: "%.3f", wallet.balanceUSD)) USD")
					Text("|")
					Text("\(wallet.nftCount) NFTs")
					
					Spacer()
					
					HStack(spacing: 4) {
						ForEach(wallet.nftIconNames, id: \.self) { nftIcon in
							Image(nftIcon)
								.resizable()
								.frame(width: 20, height: 20)
								.clipShape(Circle())
						}
					}
				}
				
				// Connection status
				Text(wallet.connectionStatusText)
					.font(.footnote)
					.foregroundColor(wallet.connectionStatusColor)
			}
		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 12)
				.foregroundColor(Color(UIColor.secondarySystemBackground))
		)
	}
}

#Preview {
	WalletCellView(
		wallet: Wallet(
			name: "Coconut",
			address: "0x888888888888ab",
			balanceUSD: 10.001,
			nftCount: 12,
			nftIconNames: ["icon1", "icon2", "icon3", "icon4"],
			chainTag: "EVM",
			isConnected: true
		)
	)
	.padding()
}
//
//#Preview {
//	ConnectingAccountButton(item: ConnectingAccountListViewModel.Item.init(
//		accountIcon: URL(string: "https://cryptologos.cc/logos/flow-flow-logo.png")!,
//		address: "0x82838483fad9d900909990903",
//		isEVM: true,
//		value: "$300.00",
//		nftCount: 5,
//		collectionIcons: nil,
//		isConnected: true
//	))
//}
