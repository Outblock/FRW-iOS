//
//  TransferListHandler.swift
//  Flow Reference Wallet
//
//  Created by Selina on 9/9/2022.
//

import UIKit

private let AllTransfersListCacheKey = "AllTransfersListCacheKey"
private let AllTransfersListCountKey = "AllTransfersListCountKey"
private let Limit: Int = 30
private let CellHeight: CGFloat = 50

class TransferListHandler: TransactionListBaseHandler {
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.alwaysBounceVertical = true
        view.dataSource = self
        view.delegate = self
        view.register(FlowTransferItemCell.self, forCellWithReuseIdentifier: "FlowTransferItemCell")
        
        view.setRefreshingAction { [weak self] in
            guard let self = self else {
                return
            }
            
            if self.collectionView.isLoading() {
                self.collectionView.stopRefreshing()
                return
            }
            
            self.requestTransfers()
        }
        
        view.setLoadingAction { [weak self] in
            guard let self = self else {
                return
            }
            
            if self.collectionView.isRefreshing() {
                self.collectionView.stopLoading()
                return
            }
            
            guard let next = self.next else {
                self.collectionView.stopLoading()
                self.collectionView.setNoMoreData(true)
                return
            }
            
            self.requestTransfers(start: next)
        }
        
        return view
    }()
    
    private var dataList: [FlowScanTransfer] = []
    private var next: String?
    
    var totalCount: Int = 0 {
        didSet {
            countChangeCallback?()
        }
    }
    
    private var isRequesting: Bool = false
    private var cacheKey: String {
        if contractId != nil {
            return "transfer_contractId_\(contractId ?? "")_key"
        } else {
            return AllTransfersListCacheKey
        }
    }
    
    var countChangeCallback: (() -> ())?
    
    override init(contractId: String? = nil) {
        super.init(contractId: contractId)
        setup()
        loadCache()
    }
    
    private func setup() {
        containerView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.beginRefreshing()
    }
    
    private func loadCache() {
        totalCount = UserDefaults.standard.integer(forKey: AllTransfersListCountKey)
        
        Task {
            if let cacheList = try? await PageCache.cache.get(forKey: cacheKey, type: [FlowScanTransfer].self) {
                DispatchQueue.main.async {
                    self.dataList = cacheList
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

extension TransferListHandler {
    func requestTransfers(start: String = "") {
        if isRequesting {
            return
        }
        
        isRequesting = true
        Task {
            do {
                if let contractId = self.contractId {
                    let request = TokenTransfersRequest(address: WalletManager.shared.getPrimaryWalletAddress() ?? "", limit: Limit, after: start, token: contractId)
                    let response: TransfersResponse = try await Network.request(FRWAPI.Account.tokenTransfers(request))
                    DispatchQueue.main.async {
                        self.isRequesting = false
                        self.requestSuccess(response, start: start)
                    }
                } else {
                    let request = TransfersRequest(address: WalletManager.shared.getPrimaryWalletAddress() ?? "", limit: Limit, after: start)
                    let response: TransfersResponse = try await Network.request(FRWAPI.Account.transfers(request))
                    DispatchQueue.main.async {
                        self.isRequesting = false
                        self.requestSuccess(response, start: start)
                    }
                }
            } catch {
                debugPrint("TransferListHandler -> requestTransfers failed: \(error)")
                
                DispatchQueue.main.async {
                    self.isRequesting = false
                    self.collectionView.stopRefreshing()
                    self.collectionView.stopLoading()
                    HUD.error(title: "transfer_request_failed".localized)
                }
            }
        }
    }
    
    private func requestSuccess(_ response: TransfersResponse, start: String) {
        var list = [FlowScanTransfer]()
        if let responseList = response.transactions {
            list = responseList
        }
        
        if start == "" {
            PageCache.cache.set(value: list, forKey: cacheKey)
        }
        
        collectionView.stopRefreshing()
        collectionView.stopLoading()
        
        if start == "" {
            dataList = list
        } else {
            dataList.append(contentsOf: list)
        }
        
        collectionView.reloadData()
        
        if let next = response.string {
            self.next = next
            collectionView.setNoMoreData(list.count < Limit)
        } else {
            collectionView.setNoMoreData(true)
        }
        
        self.totalCount = response.total ?? dataList.count
        UserDefaults.standard.set(self.totalCount, forKey: AllTransfersListCountKey)
    }
}

extension TransferListHandler: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = dataList[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlowTransferItemCell", for: indexPath) as! FlowTransferItemCell
        cell.config(item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: CellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataList[indexPath.item]
        UISelectionFeedbackGenerator().selectionChanged()
        if let txid = item.txid, let url = txid.toFlowScanTransactionDetailURL {
            Router.route(to: RouteMap.Explore.browser(url))
        }
    }
}
