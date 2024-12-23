//
//  FlowTransferItemCell.swift
//  Flow Wallet
//
//  Created by Selina on 9/9/2022.
//

import Kingfisher
import SnapKit
import SwiftUI
import UIKit

private let IconImageWidth: CGFloat = 32

// MARK: - FlowTransferItemCell

class FlowTransferItemCell: UICollectionViewCell {
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

    func config(_ model: FlowScanTransfer) {
        iconImageView.kf.setImage(
            with: model.iconURL,
            placeholder: UIImage(named: "placeholder")
        )

        let config = UIImage.SymbolConfiguration(scale: .large)
        typeImageView.image = model.transferType == .send ? UIImage(
            systemName: "arrow.up.right",
            withConfiguration: config
        ) : UIImage(systemName: "arrow.down.left", withConfiguration: config)
        titleLabel.text = model.title ?? ""

        amountlabel.text = model.amountString
        amountlabel.isHidden = amountlabel.text == "-"

        statusLabel.textColor = model.statusColor
        statusLabel.text = model.statusText

        descLabel.text = model.transferDesc
        addressLabel.text = model.transferAddress
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
        view.textColor = UIColor(named: "text.black.8")!
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

    private lazy var addressLabel: UILabel = {
        let view = UILabel()
        view.font = .inter(size: 12)
        view.textColor = UIColor.LL.Neutrals.text3
        view.lineBreakMode = .byTruncatingMiddle
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

    private func setup() {
        contentView.backgroundColor = .clear

        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(18)
        }

        let labetStack = UIStackView(arrangedSubviews: [descLabel,addressLabel])
        labetStack.axis = .horizontal
        labetStack.spacing = 0

        let stackView1 = UIStackView(arrangedSubviews: [titleStackView, labetStack])
        stackView1.axis = .vertical
        stackView1.spacing = 5
        contentView.addSubview(stackView1)
        stackView1.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }

        let stackView2 = UIStackView(arrangedSubviews: [amountlabel, statusLabel])
        stackView2.axis = .vertical
        stackView2.spacing = 5
        contentView.addSubview(stackView2)
        stackView2.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(stackView1.snp.right).offset(8)
            make.right.equalToSuperview().offset(-18)
            make.width.greaterThanOrEqualTo(60)
        }
    }
}
