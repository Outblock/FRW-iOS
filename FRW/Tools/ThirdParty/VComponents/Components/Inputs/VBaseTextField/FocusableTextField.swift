//
//  FocusableTextField.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/19/21.
//

import UIKit

// MARK: - Focusable Text Field

final class FocusableTextField: UITextField {
    // MARK: Lifecycle

    // MARK: Initializers

    init(representable: UIKitTextFieldRepresentable) {
        self.representable = representable
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    // MARK: First Responder

    override func becomeFirstResponder() -> Bool {
        representable.setBindedFocus(to: true)
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        representable.setBindedFocus(to: false)
        return super.resignFirstResponder()
    }

    // MARK: Private

    // MARK: Proeprties

    private let representable: UIKitTextFieldRepresentable
}
