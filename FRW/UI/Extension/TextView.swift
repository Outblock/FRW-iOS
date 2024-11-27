//
//  TextView.swift
//  FRW
//
//  Created by cat on 2024/8/19.
//

import SwiftUI

extension View {
    func textEditorBackground(_ content: Color) -> some View {
        if #available(iOS 16.0, *) {
            return self
                .scrollContentBackground(.hidden)
                .background(content)
        } else {
            UITextView.appearance().backgroundColor = .clear
            return background(content)
        }
    }
}
