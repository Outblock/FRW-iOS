//
//  TransactionListViewController.swift
//  Flow Reference Wallet
//
//  Created by Selina on 9/9/2022.
//

import UIKit
import SnapKit
import SwiftUI
import JXSegmentedView

class TransactionListViewController: UIViewController {
    private(set) var contractId: String?
    
    private lazy var transactionHandler: TransactionListHandler = {
        let handler = TransactionListHandler(contractId: contractId)
        handler.countChangeCallback = { [weak self] in
            self?.reloadCounts()
        }
        return handler
    }()
    
    private lazy var transferHandler: TransferListHandler = {
        let handler = TransferListHandler(contractId: contractId)
        handler.countChangeCallback = { [weak self] in
            self?.reloadCounts()
        }
        return handler
    }()
    
    private lazy var segmentDataSource: JXSegmentedTitleDataSource = {
        let ds = JXSegmentedTitleDataSource()
        ds.titles = [ "transaction_list_transfer_x".localized(transferHandler.totalCount),
                      "transaction_list_transaction_x".localized(transactionHandler.totalCount)]
        ds.titleNormalColor = UIColor.LL.Neutrals.text
        ds.titleSelectedColor = UIColor.LL.Primary.salmonPrimary
        ds.titleNormalFont = .interMedium(size: 16)
        ds.titleSelectedFont = .interMedium(size: 16)
        ds.isTitleColorGradientEnabled = true
        ds.itemSpacing = 0
        ds.itemWidth = Router.coordinator.window.bounds.size.width / 2.0
        return ds
    }()
    
    private lazy var indicator: JXSegmentedIndicatorLineView = {
        let view = JXSegmentedIndicatorLineView()
        view.indicatorCornerRadius = 0
        view.indicatorHeight = 4
        view.indicatorColor = UIColor.LL.Primary.salmonPrimary
        return view
    }()
    
    private lazy var segmentView: JXSegmentedView = {
        let view = JXSegmentedView()
        view.delegate = self
        view.dataSource = segmentDataSource
        view.indicators = [indicator]
        view.contentEdgeInsetLeft = 0
        view.contentEdgeInsetRight = 0
        return view
    }()
    
    private lazy var listContainer: JXSegmentedListContainerView = {
        let view = JXSegmentedListContainerView(dataSource: self)
        return view
    }()
    
    init(contractId: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.contractId = contractId
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setup() {
        view.backgroundColor = UIColor.LL.Neutrals.background
        
        navigationItem.hidesBackButton = true
        navigationItem.title = "wallet_transactions".localized
        
        let backItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(onBackButtonAction))
        backItem.tintColor = UIColor(named: "button.color")
        navigationItem.leftBarButtonItem = backItem
        
        view.addSubview(segmentView)
        segmentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.height.equalTo(50)
        }
        
        view.addSubview(listContainer)
        listContainer.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(segmentView.snp.bottom)
        }
        
        segmentView.listContainer = listContainer
    }
    
    @objc private func onBackButtonAction() {
        Router.pop()
    }
}

extension TransactionListViewController {
    private func reloadCounts() {
        segmentDataSource.titles = ["transaction_list_transfer_x".localized(transferHandler.totalCount),
                                    "transaction_list_transaction_x".localized(transactionHandler.totalCount)]
        segmentView.reloadData()
    }
}

extension TransactionListViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return 2
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return index == 0 ? transferHandler : transactionHandler
    }
}

extension TransactionListViewController: JXSegmentedViewDelegate {
    
}
