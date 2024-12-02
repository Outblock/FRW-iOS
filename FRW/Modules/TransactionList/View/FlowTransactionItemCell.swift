//
//  FlowTransactionItemCell.swift
//  Flow Wallet
//
//  Created by Selina on 9/9/2022.
//

import Kingfisher
import SnapKit
import SwiftUI
import UIKit

private let IconImageWidth: CGFloat = 32

// MARK: - FlowTransactionItemCell

class FlowTransactionItemCell: UICollectionViewCell {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    // MARK: Internal

    func config(_ model: FlowScanTransaction) {
        statusLabel.textColor = model.statusColor
        statusLabel.text = model.statusText
        descLabel.text = model.transactionDesc
    }

    // MARK: Private

    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon-transaction-default")

        view.snp.makeConstraints { make in
            make.width.height.equalTo(32)
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
        view.text = "-"
        view.textAlignment = .right
        return view
    }()

    private func setup() {
        contentView.backgroundColor = .clear

        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(18)
        }

        let stackView1 = UIStackView(arrangedSubviews: [titleLabel, descLabel])
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
}
