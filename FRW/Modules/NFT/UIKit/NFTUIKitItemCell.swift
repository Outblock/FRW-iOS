//
//  NFTUIKitItemCell.swift
//  Flow Reference Wallet
//
//  Created by Selina on 11/8/2022.
//

import UIKit
import SnapKit
import Kingfisher
import SwiftUI

class NFTUIKitItemCell: UICollectionViewCell {
    private var item: NFTModel?
    
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.snp.makeConstraints { make in
            make.width.equalTo(view.snp.height)
        }
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .montserratBold(size: 14)
        view.textColor = UIColor.LL.neutrals1
        return view
    }()
    
    private lazy var descLabel: UILabel = {
        let view = UILabel()
        view.font = .inter(size: 14)
        view.textColor = UIColor.LL.note
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
        }
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalTo(iconImageView)
            make.top.equalTo(iconImageView.snp.bottom).offset(8)
        }
    }
    
    func config(_ item: NFTModel) {
        self.item = item
        
        iconImageView.kf.setImage(with: item.isSVG ? item.image.absoluteString.convertedSVGURL() : item.image,
                                  placeholder: UIImage(named: "placeholder"))
        titleLabel.text = item.title
        descLabel.text = item.subtitle
    }
    
    static func calculateSize() -> CGSize {
        let width = itemWidth()
        return CGSize(width: width, height: width + 8 + 20 + 2 + 20 + 8)
    }
    
    private static func itemWidth() -> CGFloat {
        let width = Router.coordinator.window.bounds.size.width
        return (width - 18 * 3) / 2.0
    }
}

