//
//  NFTUIKitGridStyleHandler.swift
//  Flow Wallet
//
//  Created by Selina on 15/8/2022.
//

import UIKit
import SwiftUI
import SnapKit

class NFTUIKitGridStyleHandler: NSObject {
    var vm: NFTTabViewModel?
    lazy var dataModel: NFTUIKitListGridDataModel = {
        let dm = NFTUIKitListGridDataModel()
        dm.reloadCallback = { [weak self] in
            self?.reloadViews()
        }
        
        return dm
    }()
    
    private var isInitRequested: Bool = false
    private var isRequesting: Bool = false
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.LL.Neutrals.background
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.register(NFTUIKitItemCell.self, forCellWithReuseIdentifier: "NFTUIKitItemCell")
        
        view.setRefreshingAction { [weak self] in
            guard let self = self else {
                return
            }
            
            if self.collectionView.isLoading() {
                self.collectionView.stopRefreshing()
                return
            }
            
            self.refreshAction()
        }
        
        view.setLoadingAction { [weak self] in
            guard let self = self else {
                return
            }
            
            if self.collectionView.isRefreshing() {
                self.collectionView.stopLoading()
                return
            }
            
            if self.dataModel.nfts.isEmpty {
                self.collectionView.stopLoading()
                return
            }
            
            self.loadMoreAction()
        }
        
        return view
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let viewLayout = UICollectionViewFlowLayout()
        viewLayout.scrollDirection = .vertical
        viewLayout.sectionHeadersPinToVisibleBounds = true
        return viewLayout
    }()
    
    private lazy var emptyView: NFTUIKitListStyleHandler.EmptyView = {
        let view = NFTUIKitListStyleHandler.EmptyView()
        return view
    }()
    
    func setup() {
        containerView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        collectionView.reloadData()
        
        let offset = Router.coordinator.window.safeAreaInsets.top + 44.0
        containerView.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(-offset)
        }
        emptyView.isHidden = true
    }
    
    private func reloadViews() {
        if dataModel.nfts.isEmpty {
            showEmptyView()
        } else {
            hideEmptyView()
        }
        
        collectionView.reloadData()
        collectionView.setNoMoreData(dataModel.isEnd)
    }
}

extension NFTUIKitGridStyleHandler {
    func requestDataIfNeeded() {
        if dataModel.nfts.isEmpty, !isRequesting, !isInitRequested {
            collectionView.beginRefreshing()
        }
    }
    
    func refreshAction() {
        if isRequesting {
            collectionView.stopRefreshing()
            return
        }
        
        guard WalletManager.shared.getWatchAddressOrChildAccountAddressOrPrimaryAddress() != nil else {
            showEmptyView()
            return
        }
        
        isRequesting = true
        
        hideEmptyView()
        hideErrorView()
        
        Task {
            do {
                try await dataModel.requestGridAction(offset: 0)
                DispatchQueue.main.async {
                    self.isRequesting = false
                    self.isInitRequested = true
                    self.collectionView.stopRefreshing()
                    self.reloadViews()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isRequesting = false
                    self.isInitRequested = true
                    self.collectionView.stopRefreshing()
                    
                    if self.dataModel.nfts.isEmpty {
                        self.showErrorView()
                    } else {
                        HUD.error(title: "request_failed".localized)
                    }
                }
            }
        }
    }
    
    private func loadMoreAction() {
        Task {
            do {
                let offset = dataModel.nfts.count
                try await dataModel.requestGridAction(offset: offset)
                DispatchQueue.main.async {
                    if self.collectionView.isLoading() {
                        self.collectionView.stopLoading()
                    }
                    
                    self.reloadViews()
                }
            } catch {
                DispatchQueue.main.async {
                    self.collectionView.stopLoading()
                    
                    if self.dataModel.nfts.isEmpty {
                        self.showErrorView()
                    } else {
                        HUD.error(title: "request_failed".localized)
                    }
                }
            }
        }
    }
}

extension NFTUIKitGridStyleHandler {
    private func showLoadingView() {
        
    }
    
    private func hideLoadingView() {
        
    }
    
    private func showEmptyView() {
        self.emptyView.isHidden = false
    }
    
    private func hideEmptyView() {
        self.emptyView.isHidden = true
    }
    
    private func showErrorView() {
        
    }
    
    private func hideErrorView() {
        
    }
}

extension NFTUIKitGridStyleHandler: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModel.nfts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let nft = dataModel.nfts[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NFTUIKitItemCell", for: indexPath) as! NFTUIKitItemCell
        cell.config(nft)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return NFTUIKitItemCell.calculateSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vm = vm else {
            return
        }
        
        if indexPath.item < dataModel.nfts.count {
            let nft = dataModel.nfts[indexPath.item]
            Router.route(to: RouteMap.NFT.detail(vm, nft, false))
            return
        }
    }
}
