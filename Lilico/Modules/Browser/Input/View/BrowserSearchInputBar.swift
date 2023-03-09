//
//  BrowserSearchInputBar.swift
//  Lilico
//
//  Created by Selina on 1/9/2022.
//

import UIKit
import SnapKit
import SwiftUI

private let ContentViewHeight: CGFloat = 48
private let DividerWidth: CGFloat = 2
private let DividerHeight: CGFloat = 8

class BrowserSearchInputBar: UIView {
    var textDidChangedCallback: ((String) -> ())?
    
    /// tap go button directly
    var textDidReturnCallback: ((String) -> ())?
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        view.layer.borderColor = UIColor.LL.Primary.salmonPrimary.cgColor
        view.layer.borderWidth = 2
        view.heroID = "addressBarContainer"
        view.snp.makeConstraints { make in
            make.height.equalTo(ContentViewHeight)
        }
        return view
    }()
    
    lazy var textField: UITextField = {
        let view = UITextField()
        view.borderStyle = .none
        view.backgroundColor = .clear
        view.textColor = UIColor(named: "Text")
        view.font = .interSemiBold(size: 16)
        view.tintColor = UIColor.LL.Primary.salmonPrimary
        view.clearButtonMode = .never
        view.returnKeyType = .go
        view.autocorrectionType = .no
        view.delegate = self
        view.keyboardType = .webSearch
        view.snp.makeConstraints { make in
            make.height.equalTo(ContentViewHeight)
        }
        
        view.snp.contentHuggingHorizontalPriority = 249
        view.snp.contentCompressionResistanceHorizontalPriority = 749
        
        return view
    }()
    
    lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("cancel".localized, for: .normal)
        btn.setTitleColor(UIColor(named: "neutrals.note"), for: .normal)
        btn.titleLabel?.font = .interSemiBold(size: 14)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        btn.snp.makeConstraints { make in
            make.height.equalTo(ContentViewHeight)
        }
        
        return btn
    }()
    
    private lazy var divider: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = UIColor(hex: "#E3E3E3")
        
        view.snp.makeConstraints { make in
            make.width.equalTo(DividerWidth)
            make.height.equalTo(DividerHeight)
        }
        
        return view
    }()
    
    private lazy var clearBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "icon-btn-clear"))
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        btn.tintColor = UIColor.LL.Primary.salmonPrimary
        
        btn.snp.makeConstraints { make in
            make.height.equalTo(ContentViewHeight)
        }
        
        btn.addTarget(self, action: #selector(onClearBtnClick), for: .touchUpInside)
        
        return btn
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
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.right.equalTo(-18)
            make.top.equalTo(16)
            make.bottom.equalTo(-16)
        }
        
        contentView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.centerY.right.equalToSuperview()
        }
        
        contentView.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(cancelBtn.snp.left)
        }
        
        contentView.addSubview(clearBtn)
        clearBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(divider.snp.left)
        }
        
        contentView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(12)
            make.right.equalTo(clearBtn.snp.left)
        }
        
        reloadView()
        NotificationCenter.default.addObserver(self, selector: #selector(onTextFieldDidChanged(noti:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    func reloadView() {
        let isEmpty = textField.text?.isEmpty ?? true
        clearBtn.isHidden = isEmpty
    }
}

extension BrowserSearchInputBar: UITextFieldDelegate {
    @objc private func onTextFieldDidChanged(noti: Notification) {
        if noti.object as? UITextField == textField {
            reloadView()
            textDidChangedCallback?(textField.text ?? "")
        }
    }
    
    @objc private func onClearBtnClick() {
        textField.text = ""
        reloadView()
        textDidChangedCallback?("")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let text = textField.text?.trim() ?? ""
        textDidReturnCallback?(text)
        return true
    }
}
