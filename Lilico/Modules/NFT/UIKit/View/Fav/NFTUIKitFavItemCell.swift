//
//  NFTUIKitFavItemCell.swift
//  Lilico
//
//  Created by Selina on 18/8/2022.
//

import UIKit
import SwiftUI
import SnapKit
import CollectionViewPagingLayout

private let Padding: CGFloat = 12

class NFTUIKitFavItemCell: UICollectionViewCell {
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(dynamicProvider: { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor.white.withAlphaComponent(0.48)
            } else {
                return UIColor.white.withAlphaComponent(0.8)
            }
        })
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor.LL.Neutrals.background
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
        contentView.backgroundColor = .clear
        
        let height = NFTUIKitFavItemCell.calculateViewHeight()
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.width.height.equalTo(height)
            make.left.equalTo(18)
        }
        
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Padding)
            make.right.equalToSuperview().offset(-Padding)
            make.top.equalToSuperview().offset(Padding)
            make.bottom.equalToSuperview().offset(-Padding)
        }
    }
    
    func config(_ item: NFTModel) {
        imageView.kf.setImage(with: item.imageURL, placeholder: UIImage(named: "placeholder"))
    }
    
    static func calculateViewHeight() -> CGFloat {
        let maxWidth = CGFloat(Router.coordinator.window.bounds.size.width - 18 * 2)
        let itemWidth = floor(264.0/339.0 * maxWidth)
        
        return itemWidth
    }
}

extension NFTUIKitFavItemCell: StackTransformView {
    var options: StackTransformViewOptions {
        return StackTransformViewOptions(
            scaleFactor: 0.10,
            minScale: 0.6,
            maxScale: 1,
            maxStackSize: 4,
            spacingFactor: 0.2,
            maxSpacing: nil,
            alphaFactor: 0.00,
            bottomStackAlphaSpeedFactor: 0.90,
            topStackAlphaSpeedFactor: 0.30,
            perspectiveRatio: 0.30,
            shadowEnabled: true,
            shadowColor: UIColor.LL.rebackground,
            shadowOpacity: 0.10,
            shadowOffset: .zero,
            shadowRadius: 5.00,
            stackRotateAngel: 0.00,
            popAngle: 0.31,
            popOffsetRatio: .init(width: -1.45, height: 0.30),
            stackPosition: .init(x: 0.8, y: 0.00),
            reverse: false,
            blurEffectEnabled: false,
            maxBlurEffectRadius: 0.00,
            blurEffectStyle: .light
        )
    }
    
    var stackOptions: StackTransformViewOptions {
        return options
    }
}
