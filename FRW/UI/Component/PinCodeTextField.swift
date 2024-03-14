//
//  PinCodeTextField.swift
//  Flow Wallet
//
//  Created by Selina on 4/8/2022.
//

import SnapKit
import SwiftUI
import UIKit

private let ItemSize: CGFloat = 20

fileprivate class LLPinCodeItemView: UIView {
    var isTyped: Bool = false {
        didSet {
            foreHolder.isHidden = !isTyped
        }
    }
    
    private lazy var bgHolder: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.LL.Neutrals.outline
        view.layer.cornerRadius = ItemSize / 2
        return view
    }()
    
    private lazy var foreHolder: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.LL.Primary.salmonPrimary
        view.layer.cornerRadius = ItemSize / 2
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    private func setup() {
        isUserInteractionEnabled = false
        backgroundColor = .clear
        
        addSubview(bgHolder)
        bgHolder.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        addSubview(foreHolder)
        foreHolder.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        foreHolder.isHidden = true
    }
}

class LLPinCodeView: UIView, UITextInputTraits {
    public var keyboardType = UIKeyboardType.numberPad

    private let numberOfPin: Int = 6
    private let itemSpacing: CGFloat = 24
    private(set) var text: String = "" {
        didSet {
            debugPrint("LLPinCodeView text changed: \(text)")
            callback?(text)
        }
    }

    var callback: ((String) -> ())?
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(frame: bounds)
        view.axis = .horizontal
        view.spacing = itemSpacing
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    private func setup() {
        self.snp.makeConstraints { make in
            make.height.equalTo(ItemSize)
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        initItemViews()
    }
    
    private func initItemViews() {
        for _ in 0..<numberOfPin {
            let itemView = LLPinCodeItemView()
            itemView.snp.makeConstraints { make in
                make.width.height.equalTo(ItemSize)
            }
            
            stackView.addArrangedSubview(itemView)
        }
    }
    
    func changeText(_ text: String) {
        self.text = text
        reload()
    }
    
    private func reload() {
        for i in 0..<numberOfPin {
            let itemView = stackView.arrangedSubviews[i] as! LLPinCodeItemView
            itemView.isTyped = i < text.count
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: ItemSize * CGFloat(numberOfPin) + itemSpacing * CGFloat(numberOfPin - 1), height: ItemSize)
    }
}

extension LLPinCodeView: UIKeyInput {
    var hasText: Bool {
        return true
    }
    
    func insertText(_ text: String) {
        if text.count != 1 {
            return
        }
        
        if self.text.count >= numberOfPin {
            return
        }
        
        let scanner = Scanner(string: text)
        let result = scanner.scanInt(nil)
        if !result {
            return
        }
        
        self.text = self.text.appending(text)
        reload()
    }
    
    func deleteBackward() {
        if text.isEmpty {
            return
        }
        
        text.removeLast(1)
        reload()
    }
}

extension LLPinCodeView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isFirstResponder {
            becomeFirstResponder()
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}

struct PinCodeTextField: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> LLPinCodeView {
        let view = LLPinCodeView()
        return view
    }
    
    func updateUIView(_ uiView: LLPinCodeView, context: Context) {
        uiView.callback = { newText in
            text = newText
        }
        
        if uiView.text != text {
            uiView.changeText(text)
        }
    }
}
