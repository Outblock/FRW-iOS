//
//  TransactionListBaseHandler.swift
//  Flow Wallet
//
//  Created by Selina on 9/9/2022.
//

import JXSegmentedView
import SnapKit
import UIKit

class TransactionListBaseHandler: NSObject {
    private(set) var contractId: String?

    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    init(contractId: String? = nil) {
        self.contractId = contractId
    }
}

extension TransactionListBaseHandler: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return containerView
    }
}
