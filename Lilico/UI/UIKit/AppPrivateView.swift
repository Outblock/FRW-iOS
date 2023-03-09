//
//  AppPrivateView.swift
//  Lilico
//
//  Created by Selina on 15/9/2022.
//

import UIKit
import SnapKit

class AppPrivateView: UIView {
    private lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let image = UIImage(named: "lilicat-grey")
        let view = UIImageView(image: image)
//        view.clipsToBounds = true
//        view.layer.cornerRadius = 40
        
        view.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setup() {
        backgroundColor = .clear
        
        addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
