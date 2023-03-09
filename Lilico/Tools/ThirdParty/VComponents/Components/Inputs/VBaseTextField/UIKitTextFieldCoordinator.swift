//
//  VBaseTextFieldCoordinator.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/19/21.
//

import SwiftUI

// MARK: - UIKit Text Field Coordinator

extension UIKitTextFieldRepresentable {
    final class Coordinator: NSObject, UITextFieldDelegate {
        // MARK: Properties

        private let representable: UIKitTextFieldRepresentable

        // MARK: Initializers

        init(representable: UIKitTextFieldRepresentable) {
            self.representable = representable
            super.init()
        }

        // MARK: Text Field Delegate

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            switch representable.returnAction {
            case .return:
                representable.textFieldReturned(textField)
                return true

            case let .custom(action):
                action()
                return false

            case let .returnAndCustom(action):
                action()
                representable.textFieldReturned(textField)
                return true
            }
        }

        func textFieldDidBeginEditing(_: UITextField) {
            representable.beginHandler?()
        }

        @objc func textFieldDidChange(_ textField: UITextField) {
            representable.commitText(textField.text ?? "")
            representable.changeHandler?()
        }

        func textFieldDidEndEditing(_: UITextField) {
            representable.endHandler?()
        }
    }
}
