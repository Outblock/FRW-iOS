//
//  NFTUIKitListTitleView.swift
//  Flow Wallet
//
//  Created by Selina on 13/8/2022.
//

import SnapKit
import SwiftUI
import UIKit

class NFTUIKitListTitleView: UIView {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.LL.Neutrals.background

        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.centerY.equalToSuperview()
        }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }

        addSubview(switchButton)
        switchButton.snp.makeConstraints { make in
            make.right.equalTo(-18)
            make.centerY.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    lazy var switchButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "nft_logo_grid_layout"), for: .normal)
        return button
    }()

    // MARK: Private

    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "nft_logo_collection")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = UIColor.LL.neutrals1
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .montserratBold(size: 22)
        label.textColor = UIColor.LL.neutrals1
        label.text = "collections".localized
        return label
    }()
}
