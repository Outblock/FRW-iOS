//
//  NFTUIKitGridStyleHandler.swift
//  Flow Wallet
//
//  Created by Selina on 15/8/2022.
//

import SnapKit
import SwiftUI
import UIKit

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
        view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")

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
    private func showLoadingView() {}

    private func hideLoadingView() {}

    private func showEmptyView() {
        emptyView.isHidden = false
    }

    private func hideEmptyView() {
        emptyView.isHidden = true
    }

    private func showErrorView() {}

    private func hideErrorView() {}
}

extension NFTUIKitGridStyleHandler: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return dataModel.nfts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let nft = dataModel.nfts[safe: indexPath.item] {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NFTUIKitItemCell", for: indexPath) as! NFTUIKitItemCell
            cell.config(nft)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return NFTUIKitItemCell.calculateSize()
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        return .zero
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForFooterInSection _: Int) -> CGSize {
        return .zero
    }

    func collectionView(_: UICollectionView, viewForSupplementaryElementOfKind _: String, at _: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 18
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 18
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vm = vm else {
            return
        }

        if indexPath.item < dataModel.nfts.count {
            let nft = dataModel.nfts[indexPath.item]
            Router.route(to: RouteMap.NFT.detail(vm, nft, nil))
            return
        }
    }
}
