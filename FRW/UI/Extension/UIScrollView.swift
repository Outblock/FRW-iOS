//
//  UIScrollView.swift
//  Flow Wallet
//
//  Created by Selina on 11/8/2022.
//

import MJRefresh
import UIKit

extension UIScrollView {
    // refreshing

    public func setRefreshingAction(_ action: @escaping () -> Void) {
        let header = MJRefreshGifHeader(refreshingBlock: action)

        var images: [UIImage] = []
        for i in 0...95 {
            let image = UIImage(named: "refresh-header-seq-\(i)")!
            images.append(image)
        }

        let duration: TimeInterval = 1.6
        header.setImages([images.first!], duration: duration, for: .idle)
        header.setImages(images, duration: duration, for: .pulling)
        header.setImages(images, duration: duration, for: .refreshing)

        header.lastUpdatedTimeLabel?.isHidden = true
        header.stateLabel?.isHidden = true
        header.isAutomaticallyChangeAlpha = true
        mj_header = header
    }

    public func beginRefreshing() {
        mj_header?.beginRefreshing()
    }

    public func stopRefreshing() {
        if isRefreshing() {
            mj_header?.endRefreshing()
        }
    }

    public func isRefreshing() -> Bool {
        mj_header?.isRefreshing ?? false
    }

    // loading

    public func setLoadingAction(
        _ action: @escaping () -> Void,
        noMoreDataLabelEnabled: Bool = true
    ) {
        let footer = MJRefreshAutoStateFooter(refreshingBlock: action)
        footer.stateLabel?.textColor = UIColor(hex: "#888888")
        footer.stateLabel?.font = UIFont.systemFont(ofSize: 14)
        footer.setTitle("pull_up_load_more".localized, for: .idle)
        footer.setTitle("release_load_more".localized, for: .pulling)
        footer.setTitle("loading_more".localized, for: .refreshing)
        footer.setTitle(noMoreDataLabelEnabled ? "no_more_data".localized : "", for: .noMoreData)
        footer.triggerAutomaticallyRefreshPercent = 1
        footer.isAutomaticallyChangeAlpha = true
        mj_footer = footer
    }

    public func removeLoadingAction() {
        mj_footer = nil
    }

    public func beginLoading() {
        mj_footer?.beginRefreshing()
    }

    public func stopLoading() {
        if isLoading() {
            mj_footer?.endRefreshing()
        }
    }

    public func isLoading() -> Bool {
        mj_footer?.isRefreshing ?? false
    }

    public func setNoMoreData(_ noMore: Bool) {
        if noMore {
            mj_footer?.endRefreshingWithNoMoreData()
            return
        }

        mj_footer?.resetNoMoreData()
    }
}

extension UIScrollView {
    public func scrollToTop(animated: Bool = true) {
        var off = contentOffset
        off.y = 0 - contentInset.top
        setContentOffset(off, animated: animated)
    }
}
