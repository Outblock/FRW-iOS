//
//  NFTUIKitCollectionHContainerView.swift
//  Lilico
//
//  Created by Selina on 11/8/2022.
//

import UIKit
import SnapKit
import SwiftUI

class NFTUIKitCollectionHContainerView: UIView {
    var items: [CollectionItem] = []
    var selectedIndex: Int = 0
    
    var didSelectIndexCallback: ((Int) -> ())?
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.bounces = false
        view.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.contentInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.register(NFTUIKitCollectionItemCell.self, forCellWithReuseIdentifier: "NFTUIKitCollectionItemCell")
        return view
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let viewLayout = UICollectionViewFlowLayout()
        viewLayout.scrollDirection = .horizontal
        viewLayout.minimumLineSpacing = 12
        viewLayout.minimumInteritemSpacing = 12
        return viewLayout
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = UIColor.LL.Neutrals.background
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(56)
        }
    }
    
    func reloadViews() {
        collectionView.reloadData()
    }
}

extension NFTUIKitCollectionHContainerView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NFTUIKitCollectionItemCell", for: indexPath) as! NFTUIKitCollectionItemCell
        let item = items[indexPath.item]
        cell.config(item, isSelectItem: indexPath.item == selectedIndex)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = items[indexPath.item]
        return NFTUIKitCollectionItemCell.calculateSize(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        collectionView.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        didSelectIndexCallback?(selectedIndex)
    }
}
