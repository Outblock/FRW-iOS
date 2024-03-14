//
//  TransactionListView.swift
//  Flow Wallet
//
//  Created by Selina on 29/8/2022.
//

import UIKit
import SwiftUI
import SnapKit
import Flow
import Kingfisher

private let CellHeight: CGFloat = 48

class TransactionListCell: UIView {
    private(set) var model: TransactionManager.TransactionHolder?
    
    private lazy var progressView: TransactionProgressView = {
        let view = TransactionProgressView()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.LL.Neutrals.text
        label.font = .inter(size: 14)
        label.text = "pending_transaction".localized
        label.snp.contentHuggingHorizontalPriority = 249
        label.snp.contentCompressionResistanceHorizontalPriority = 749
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: .delete), for: .normal)
        
        btn.snp.makeConstraints { make in
            make.width.height.equalTo(44)
        }
        
        return btn
    }()
    
    private lazy var bgMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.LL.Button.text
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    private func setup() {
        backgroundColor = .clear
        layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 3)
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(progressView.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
        
//        contentView.addSubview(deleteButton)
//        deleteButton.snp.makeConstraints { make in
//            make.left.equalTo(titleLabel.snp.right).offset(5)
//            make.centerY.equalToSuperview()
//            make.right.equalToSuperview().offset(-5)
//        }
        
        contentView.layer.mask = bgMaskLayer
        
        self.snp.makeConstraints { make in
            make.height.equalTo(CellHeight)
        }
        
        addNotification()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tap)
    }
    
    @objc private func onTap() {
        if let id = model?.transactionId {
            Router.route(to: RouteMap.Transaction.detail(id))
        }
    }
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onHolderStatusChanged(noti:)), name: .transactionStatusDidChanged, object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reloadBgPaths()
    }
    
    private func reloadBgPaths() {
        bgMaskLayer.frame = bounds
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: 24.0, height: 24.0))
        bgMaskLayer.path = path.cgPath
    }
    
    func config(_ model: TransactionManager.TransactionHolder) {
        self.model = model
        refreshView()
    }
    
    @objc private func onHolderStatusChanged(noti: Notification) {
        guard let holder = noti.object as? TransactionManager.TransactionHolder, let current = model, current.transactionId.hex == holder.transactionId.hex else {
            return
        }
        
        refreshView()
    }
    
    private func refreshView() {
        if let iconURL = model?.icon() {
            progressView.iconImageView.kf.setImage(with: iconURL, placeholder: UIImage(named: "placeholder"))
        } else {
            progressView.iconImageView.image = UIImage(named: "flow")
        }
        
        if model?.internalStatus == .failed {
            progressView.progress = 1
        } else {
            progressView.progress = model?.flowStatus.progressPercent ?? 0
        }
        
        if let strokeColor = model?.internalStatus.statusColor {
            progressView.changeProgressColor(strokeColor)
        }
    }
}

class TransactionListView: UIView {
    private lazy var bgView: UIVisualEffectView = {
        let view = UIVisualEffectView(style: .systemChromeMaterial)
//        view.backgroundColor = .white.withAlphaComponent(0.7)
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [])
        view.axis = .vertical
        view.spacing = 10
        view.alignment = .trailing
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    private func setup() {
        backgroundColor = .clear
        
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.equalTo(40)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(gesture)
    }
    
    @objc private func onTap() {
        TransactionUIHandler.shared.dismissListView()
    }
    
    private func removeAllCells() {
        while stackView.arrangedSubviews.count != 0 {
            let view = stackView.arrangedSubviews.first!
            view.removeFromSuperview()
        }
    }
    
    func refresh() {
        removeAllCells()
        
        for holder in TransactionManager.shared.holders {
            let cell = TransactionListCell()
            cell.config(holder)
            stackView.addArrangedSubview(cell)
        }
    }
}
