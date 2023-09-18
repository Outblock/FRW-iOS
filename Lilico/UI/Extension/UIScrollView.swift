//
//  UIScrollView.swift
//  Flow Reference Wallet
//
//  Created by Selina on 11/8/2022.
//

import UIKit
import MJRefresh

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
        self.mj_header = header
    }
    
    public func beginRefreshing() {
        self.mj_header?.beginRefreshing()
    }
    
    public func stopRefreshing() {
        if isRefreshing() {
            self.mj_header?.endRefreshing()
        }
    }
    
    public func isRefreshing() -> Bool {
        return self.mj_header?.isRefreshing ?? false
    }
    
    // loading
    
    public func setLoadingAction(_ action: @escaping () -> Void, noMoreDataLabelEnabled: Bool = true) {
        let footer = MJRefreshAutoStateFooter(refreshingBlock: action)
        footer.stateLabel?.textColor = UIColor(hex: "#888888")
        footer.stateLabel?.font = UIFont.systemFont(ofSize: 14)
        footer.setTitle("pull_up_load_more".localized, for: .idle)
        footer.setTitle("release_load_more".localized, for: .pulling)
        footer.setTitle("loading_more".localized, for: .refreshing)
        footer.setTitle(noMoreDataLabelEnabled ? "no_more_data".localized : "", for: .noMoreData)
        footer.triggerAutomaticallyRefreshPercent = 1
        footer.isAutomaticallyChangeAlpha = true
        self.mj_footer = footer
    }
    
    public func removeLoadingAction() {
        self.mj_footer = nil
    }
    
    public func beginLoading() {
        self.mj_footer?.beginRefreshing()
    }
    
    public func stopLoading() {
        if isLoading() {
            self.mj_footer?.endRefreshing()
        }
    }
    
    public func isLoading() -> Bool {
        return self.mj_footer?.isRefreshing ?? false
    }
    
    public func setNoMoreData(_ noMore: Bool) {
        if noMore {
            self.mj_footer?.endRefreshingWithNoMoreData()
            return
        }
        
        self.mj_footer?.resetNoMoreData()
    }
}

extension UIScrollView {
    public func scrollToTop(animated: Bool = true) {
        var off = self.contentOffset
        off.y = 0 - self.contentInset.top
        self.setContentOffset(off, animated: animated)
    }
}
