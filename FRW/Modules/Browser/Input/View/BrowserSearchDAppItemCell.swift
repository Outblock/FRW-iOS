//
//  BrowserSearchDAppItemCell.swift
//  Flow Wallet
//
//  Created by Selina on 8/10/2022.
//

import Kingfisher
import SnapKit
import UIKit

class BrowserSearchDAppItemCell: UICollectionViewCell {
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

    func config(_ model: DAppModel) {
        iconImageView.setImage(with: model.logo)
        titleLabel.text = model.name
        descLabel.text = model.host
    }

    // MARK: Private

    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true

        view.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }

        view.layer.cornerRadius = 18

        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .montserratBold(size: 14)
        view.textColor = UIColor.LL.Neutrals.text
        view.text = ""
        return view
    }()

    private lazy var descLabel: UILabel = {
        let view = UILabel()
        view.font = .inter(size: 14)
        view.textColor = UIColor.LL.Neutrals.text
        view.text = ""
        return view
    }()

    private func setup() {
        contentView.backgroundColor = .clear

        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.centerY.equalToSuperview()
        }

        let stackView = UIStackView(arrangedSubviews: [titleLabel, descLabel])
        stackView.axis = .vertical
        stackView.spacing = 5

        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
    }
}
