//
//  Item.swift
//  FRW
//
//  Created by Marty Ulrich on 1/21/25.
//

import Foundation
import Flow

@MainActor
class ConnectingAccountListViewModel: ObservableObject {
	struct Item: Identifiable {
		var id: String { address }
		let accountIcon: URL
		let address: String
		let isEVM: Bool
		let value: String
		let nftCount: Int
		let collectionIcons: [URL]?
		let isConnected: Bool
	}
	
	let connectingAccount: Item
	let compatibleAccounts: [Item]
	let incompatibleAccounts: [Item]
	
	init(connectingAccount: Item, compatibleAccounts: [Item], incompatibleAccounts: [Item]) {
		self.connectingAccount = connectingAccount
		self.compatibleAccounts = compatibleAccounts
		self.incompatibleAccounts = incompatibleAccounts
	}
	
	func learnMoreTapped() {
		
	}
	
	func itemSelected(id: String) {
		
	}
}
