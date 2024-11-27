//
//  CalloutView.swift
//  Flow Wallet
//
//  Created by cat on 2023/7/26.
//

import SwiftUI
import SwiftUIX

// MARK: - CalloutType

enum CalloutType: String {
    case tip, warning, failure

    // MARK: Internal

    func iconName() -> String {
        "callout_icon_" + rawValue
    }
}

// MARK: - CalloutView

struct CalloutView: View {
    var type = CalloutType.warning
    var corners: [RectangleCorner] = []
    @State
    var content: String?

    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 5) {
                Image(type.iconName())
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color.Theme.Accent.orange)
                    .frame(size: CGSize(width: 16, height: 16))

                Text(content ?? "")
                    .font(Font.inter(size: 12))
                    .foregroundColor(Color.Theme.Accent.orange)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.Theme.Accent.orange.opacity(0.16))
        .cornerRadius(corners, 8)
        .hidden((content == nil) ? true : false)
    }
}

// MARK: - CalloutView_Previews

struct CalloutView_Previews: PreviewProvider {
    static var previews: some View {
        CalloutView(content: "hello world")
    }
}
