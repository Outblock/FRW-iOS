//
//  NFTUIKitTopSelectionHeaderView.swift
//  Flow Wallet
//
//  Created by Selina on 19/8/2022.
//

import SwiftUI
import UIKit

class NFTUIKitTopSelectionHeaderView: UIView {
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon-nft-top-selection")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .white
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .montserratBold(size: 22)
        label.textColor = .white
        label.text = "top_selection".localized
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("")
    }

    private func setup() {
        backgroundColor = .clear

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
    }
}
