//
//  NFTUIKitCollectionItemCell.swift
//  Flow Wallet
//
//  Created by Selina on 11/8/2022.
//

import Kingfisher
import SnapKit
import SwiftUI
import UIKit

private let CellHeight: CGFloat = 56
private let IconSize: CGFloat = 40
private let Padding: CGFloat = 8

// MARK: - NFTUIKitCollectionItemCell

class NFTUIKitCollectionItemCell: UICollectionViewCell {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    static func calculateSize(_ item: CollectionItem) -> CGSize {
        var baseWidth: CGFloat = Padding + IconSize + Padding + Padding
        let titleWidth = baseWidth + item.showName
            .width(withFont: .montserratBold(size: 14)) + 3 + 12
        let descWidth = baseWidth + "x_collections".localized(item.count)
            .width(withFont: .inter(size: 14))

        return CGSize(width: max(titleWidth, descWidth), height: CellHeight)
    }

    func config(_ item: CollectionItem, isSelectItem: Bool) {
        self.item = item
        self.isSelectItem = isSelectItem

        iconImageView.kf.setImage(with: item.iconURL, placeholder: UIImage(named: "placeholder"))
        titleLabel.text = item.showName
        if let info = item.collection, !WalletManager.shared.accessibleManager.isAccessible(info) {
            descLabel.isHidden = true
            inaccessibleLabel.isHidden = false
        } else {
            descLabel.isHidden = false
            inaccessibleLabel.isHidden = true
        }

        descLabel.text = "x_collections".localized(item.count)

        contentView.layer.borderColor = isSelectItem ? UIColor.LL.Neutrals.neutrals3
            .cgColor : UIColor.clear.cgColor
    }

    // MARK: Private

    private var item: CollectionItem?
    private var isSelectItem: Bool = false

    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.snp.makeConstraints { make in
            make.width.height.equalTo(IconSize)
        }
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .montserratBold(size: 14)
        view.textColor = UIColor.LL.neutrals1
        return view
    }()

    private lazy var markIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Flow")
        view.snp.makeConstraints { make in
            make.width.height.equalTo(12)
        }
        return view
    }()

    private lazy var inaccessibleLabel: UIView = {
        let container = UIView()
        container.layer.cornerRadius = 4
        container.backgroundColor = UIColor.Theme.Accent.grey?.withAlphaComponent(0.16)

        let view = UILabel()
        view.font = .inter(size: 10)
        view.textAlignment = .center
        view.text = "Inaccessible".localized
        view.textColor = UIColor.Theme.Accent.grey
        container.addSubview(view)
        view.snp.makeConstraints { make in
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
        }
        return container
    }()

    private lazy var descLabel: UILabel = {
        let view = UILabel()
        view.font = .inter(size: 14)
        view.textColor = UIColor.LL.note
        return view
    }()

    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, markIcon])
        stackView.axis = .horizontal
        stackView.spacing = 3
        return stackView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [hStackView, descLabel, inaccessibleLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 5
        return stackView
    }()

    private func setup() {
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.equalTo(Padding)
            make.centerY.equalToSuperview()
        }

        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(Padding)
            make.centerY.equalToSuperview()
        }

        contentView.backgroundColor = UIColor.LL.frontColor
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
    }
}
