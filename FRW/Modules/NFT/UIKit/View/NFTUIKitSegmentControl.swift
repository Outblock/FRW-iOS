//
//  NFTUIKitSegmentControl.swift
//  Flow Wallet
//
//  Created by Selina on 16/8/2022.
//

import UIKit
import SwiftUI

private let Height: CGFloat = 32
private let ButtonHeight: CGFloat = 24

class NFTUIKitSegmentControl: UIView {
    var names: [String]
    var selectedIndex: Int = 0
    var callback: ((Int) -> ())?
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [])
        view.axis = .horizontal
        view.spacing = 0
        return view
    }()
    
    private lazy var selectBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(dynamicProvider: { trait in
            if trait.userInterfaceStyle == .dark {
                return .black
            } else {
                return .white
            }
        })
        view.layer.cornerRadius = ButtonHeight * 0.5
        return view
    }()
    
    private var unselectColor: UIColor {
        return UIColor.LL.frontColor
    }
    
    private var selectedColor: UIColor {
        return UIColor.LL.Neutrals.text
    }
    
    required init(names: [String]) {
        self.names = names
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    private func setupViews() {
        backgroundColor = UIColor.LL.Neutrals.neutrals3.withAlphaComponent(0.24)
        layer.cornerRadius = Height * 0.5
        clipsToBounds = true
        
        addSubview(selectBgView)
        
        for (index, name) in names.enumerated() {
            let button = createButton(name: name)
            button.tag = index
            button.addTarget(self, action: #selector(onButtonClick(button:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.left.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.right.equalToSuperview().offset(-4)
        }
        
        refreshSelectBgView()
        refreshButtons()
    }
    
    private func createButton(name: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(name, for: .normal)
        button.titleLabel?.font = .interSemiBold(size: 14)
        
        button.setTitleColor(unselectColor, for: .normal)
        button.setTitleColor(unselectColor, for: .highlighted)
        button.setTitleColor(selectedColor, for: .selected)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 13)
        button.isExclusiveTouch = true
        
        button.snp.makeConstraints { make in
            make.height.equalTo(ButtonHeight)
        }
        
        return button
    }
    
    @objc private func onButtonClick(button: UIButton) {
        changeSelectIndex(index: button.tag)
    }
    
    private func changeSelectIndex(index: Int) {
        if selectedIndex == index {
            return
        }
        
        selectedIndex = index
        UIView.animate(withDuration: 0.2) {
            self.refreshButtons()
            self.refreshSelectBgView()
            self.layoutIfNeeded()
        }
        
        callback?(index)
    }
    
    private func refreshButtons() {
        for (index, button) in stackView.arrangedSubviews.enumerated() {
            let b = button as! UIButton
            b.isSelected = index == selectedIndex
        }
    }
    
    private func refreshSelectBgView() {
        let selectBtn = stackView.arrangedSubviews[selectedIndex]
        selectBgView.snp.remakeConstraints { make in
            make.height.equalTo(ButtonHeight)
            make.width.equalTo(selectBtn)
            make.center.equalTo(selectBtn)
        }
    }
}
