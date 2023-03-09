//
//  FlowTransferItemCell.swift
//  Lilico
//
//  Created by Selina on 9/9/2022.
//

import UIKit
import Kingfisher
import SwiftUI
import SnapKit

private let IconImageWidth: CGFloat = 32

class FlowTransferItemCell: UICollectionViewCell {
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon-transaction-default")
        
        view.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }
        return view
    }()
    
    private lazy var typeImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = UIColor.LL.Neutrals.text
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.snp.makeConstraints { make in
            make.width.height.equalTo(12)
        }
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .interSemiBold(size: 14)
        view.textColor = UIColor.LL.Neutrals.text
        view.text = "transaction_exec".localized
        return view
    }()
    
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [typeImageView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }()
    
    private lazy var descLabel: UILabel = {
        let view = UILabel()
        view.font = .inter(size: 12)
        view.textColor = UIColor.LL.Neutrals.text3
        return view
    }()
    
    private lazy var statusLabel: UILabel = {
        let view = UILabel()
        view.font = .inter(size: 12)
        view.textColor = UIColor.LL.Neutrals.text3
        view.textAlignment = .right
        return view
    }()
    
    private lazy var amountlabel: UILabel = {
        let view = UILabel()
        view.font = .inter(size: 14)
        view.textColor = UIColor.LL.Neutrals.text
        view.textAlignment = .right
        view.text = "-"
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setup() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(18)
        }
        
        let stackView1 = UIStackView(arrangedSubviews: [titleStackView, descLabel])
        stackView1.axis = .vertical
        stackView1.spacing = 5
        contentView.addSubview(stackView1)
        stackView1.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-18)
        }
        
        let stackView2 = UIStackView(arrangedSubviews: [amountlabel, statusLabel])
        stackView2.axis = .vertical
        stackView2.spacing = 5
        contentView.addSubview(stackView2)
        stackView2.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-18)
        }
    }
    
    func config(_ model: FlowScanTransfer) {
        iconImageView.kf.setImage(with: URL(string: model.image ?? ""), placeholder: UIImage(named: "placeholder"))
        
        let config = UIImage.SymbolConfiguration(scale: .large)
        typeImageView.image = model.transferType == .send ? UIImage(systemName: "arrow.up.right", withConfiguration: config) : UIImage(systemName: "arrow.down.left", withConfiguration: config)
        titleLabel.text = model.token?.replaceBeforeLast(".", replacement: "").removePrefix(".")
        
        amountlabel.text = model.amountString
        amountlabel.isHidden = amountlabel.text == "-"
        
        statusLabel.textColor = model.statusColor
        statusLabel.text = model.statusText
        
        descLabel.text = model.transferDesc
    }
}
