//
//  NFTUIKitItemCell.swift
//  Flow Wallet
//
//  Created by Selina on 11/8/2022.
//

import UIKit
import SnapKit
import Kingfisher
import SwiftUI
import PocketSVG

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
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descLabel, inaccessibleLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
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
        if let svgStr = item.imageSVGStr {
            if let img = generateSVGImage(svgString: svgStr) {
                iconImageView.image = img
            }else {
                iconImageView.image = UIImage(named: "placeholder")
            }
            
        }else {
            iconImageView.kf.setImage(with: item.isSVG ? item.image.absoluteString.convertedSVGURL() : item.image,
                                      placeholder: UIImage(named: "placeholder"))
        }
        
        titleLabel.text = item.title
        descLabel.text = item.subtitle
        if let info = item.collection, !WalletManager.shared.accessibleManager.isAccessible(info) {
            descLabel.isHidden = true
            inaccessibleLabel.isHidden = false
        }else {
            descLabel.isHidden = false
            inaccessibleLabel.isHidden = true
        }
    }
    
    
    func generateSVGImage(svgString: String) -> UIImage? {
        let width = NFTUIKitItemCell.itemWidth()
        
        let svgLayer = SVGLayer()
        svgLayer.paths = SVGBezierPath.paths(fromSVGString: svgString)
        let originRect = SVGBoundingRectForPaths(svgLayer.paths)
        svgLayer.frame = CGRect(x: 0, y: 0, width: width, height: width * originRect.height / originRect.width)
        return snapshotImage(for: svgLayer)
    }
    
    func snapshotImage(for layer: CALayer) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
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

