//
//  NFTUIKitCollectionRegularItemCell.swift
//  Flow Wallet
//
//  Created by Selina on 13/8/2022.
//

import UIKit
import SnapKit
import Kingfisher
import SwiftUI

private let CellHeight: CGFloat = 64
private let IconSize: CGFloat = 48
private let Padding: CGFloat = 8

class NFTUIKitCollectionRegularItemCell: UICollectionViewCell {
    private var item: CollectionItem?
    
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
        let stackView = UIStackView(arrangedSubviews: [hStackView, descLabel])
        stackView.axis = .vertical
        stackView.spacing = 3
        return stackView
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "arrow_right_grey")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = UIColor.LL.Primary.salmonPrimary
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        contentView.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 12, height: 12))
            make.left.equalTo(stackView.snp.right).offset(Padding)
        }
        
        contentView.backgroundColor = UIColor.LL.frontColor
        contentView.layer.cornerRadius = 16
    }
    
    func config(_ item: CollectionItem) {
        self.item = item
        
        iconImageView.kf.setImage(with: item.iconURL)
        titleLabel.text = item.showName
        descLabel.text = "x_collections".localized(item.count)
    }
    
    static func calculateSize() -> CGSize {
        let width = Router.coordinator.window.bounds.size.width - 18 * 2
        return CGSize(width: width, height: CellHeight)
    }
}
