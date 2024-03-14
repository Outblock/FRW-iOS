//
//  TransactionListBaseHandler.swift
//  Flow Wallet
//
//  Created by Selina on 9/9/2022.
//

import UIKit
import JXSegmentedView
import SnapKit

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
