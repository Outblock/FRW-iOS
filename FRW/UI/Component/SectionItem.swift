//
//  SectionItem.swift
//  FRW
//
//  Created by cat on 10/30/24.
//

import Introspect
import SwiftUI

// MARK: - TitleView

struct TitleView: View {
    let title: String
    let isStar: Bool

    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.inter(size: 14, weight: .bold))
                .foregroundStyle(Color.Theme.Text.black)
            if isStar {
                Text(" *")
                    .font(.inter(size: 14, weight: .bold))
                    .foregroundStyle(Color.Theme.Accent.red)
            }
            Spacer()
        }
    }
}

// MARK: - SingleInputView

struct SingleInputView: View {
    enum FocusField: Hashable {
        case field
    }

    @Binding
    var content: String
    var placeholder: String? = "add_custom_token_place".localized
    @FocusState
    private var focusedField: FocusField?
    var onSubmit: EmptyClosure? = nil
    var onChange: ((String) -> Void)? = nil

    var body: some View {
        ZStack(alignment: .center) {
            TextField("", text: $content)
                .keyboardType(.alphabet)
                .submitLabel(.search)
                .disableAutocorrection(true)
                .modifier(PlaceholderStyle(
                    showPlaceHolder: content.isEmpty,
                    placeholder: placeholder ?? "",
                    font: .inter(size: 14, weight: .medium),
                    color: Color.LL.Neutrals.note
                ))
                .font(.inter(size: 14))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onSubmit {
                    onSubmit?()
                }
                .onChange(of: content) { text in
                    withAnimation {
                        onChange?(text)
                    }
                }
                .focused($focusedField, equals: .field)
                .onAppear {
                    self.focusedField = .field
                }
        }
        .padding(20)
        .frame(height: 64)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(.Theme.BG.bg1)
        }
    }
}

#Preview {
    TitleView(title: "Hello", isStar: false)

    SingleInputView(content: .constant("abc"), onChange: { str in

    })
}
