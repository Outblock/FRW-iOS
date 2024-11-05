//
//  ImportTitleHeader.swift
//  FRW
//
//  Created by cat on 10/30/24.
//

import SwiftUI
import Introspect

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

struct SingleInputView: View {
    
    enum FocusField: Hashable {
        case field
    }
    
    @Binding var content: String
    var placeholder: String? = "add_custom_token_place".localized
    @FocusState private var focusedField: FocusField?
    var onSubmit: EmptyClosure? = nil
    var onChange: ((String)->())? = nil
    
    var body: some View {
        ZStack(alignment: .center) {
            
            TextField("", text: $content)
                .keyboardType(.alphabet)
                .submitLabel(.search)
                .disableAutocorrection(true)
                .modifier(PlaceholderStyle(showPlaceHolder: content.isEmpty,
                                           placeholder: placeholder ?? "",
                                           font: .inter(size: 14, weight: .medium),
                                           color: Color.LL.Neutrals.note))
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






public struct AnimatedSecureTextField: View {
    private enum FocusedField: Int, Hashable {
        case password
    }

    @State var isSecure = false
    @FocusState private var field: FocusedField?
    public let placeholder: String
    @Binding var text: String

    var textDidChange:(String)->()
    
    public init(placeholder: String, text: Binding<String>, textDidChange: @escaping (String)->()) {
        self.placeholder = placeholder
        self._text = text
        self.textDidChange = textDidChange
        self.field = .password
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            if  text.isEmpty {
                HStack {
                    Text(placeholder)
                        .font(.inter(size: 14))
                        .foregroundStyle(Color.Theme.Text.black3)
                    Spacer()
                }
    //            .padding(.horizontal, 16.0)
                .frame(maxWidth: .infinity)
                .layoutPriority(1)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        field = .password
                    }
                }
            }
            

            if isSecure {
                SecureField("", text: $text)
                    .disableAutocorrection(true)
                    .foregroundStyle(Color.Theme.Text.black)
                    .autocapitalization(.none)
                    .frame(maxWidth: .infinity)
                    .focused($field, equals: .password)
                    .font(.inter(size: 14))
                    .contentShape(Rectangle())
                    .onChange(of: text) { text in
                        textDidChange(text)
                    }
                    
            } else {
                TextField("", text: $text)
                    .disableAutocorrection(true)
                    .foregroundStyle(Color.Theme.Text.black)
                    .autocapitalization(.none)
                    .frame(maxWidth: .infinity)
                    .focused($field, equals: .password)
                    .font(.inter(size: 14))
                    .contentShape(Rectangle())
                    .onChange(of: text) { text in
                        textDidChange(text)
                    }
                    
            }

            HStack {
                Spacer()
                    
                if !text.isEmpty {
                    Button {
                        isSecure.toggle()
                    } label: {
                        if isSecure {
                            Image(systemName: "eye")
                                .resizable()
                                .foregroundStyle(Color.Theme.Text.black)
                                .frame(width: 20, height: 12)
                        } else {
                            Image(systemName: "eye.slash")
                                .resizable()
                                .foregroundStyle(Color.Theme.Text.black)
                                .frame(width: 20, height: 12)
                        }
                    }
                }
            }
        }
        .padding(.horizontal,20)
        .frame(height: 64)
        .background {
            RoundedRectangle(cornerRadius: 16.0)
                .foregroundColor(.Theme.Background.bg2)
        }
    }
}


#Preview {
    TitleView(title: "Hello", isStar: false)
    
    SingleInputView(content: .constant("abc")) { str in
    
    }
}
