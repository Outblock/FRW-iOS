//
//  CalloutView.swift
//  Flow Reference Wallet
//
//  Created by cat on 2023/7/26.
//

import SwiftUI
import SwiftUIX

enum CalloutType: String {
    case tip,warning,failure
        func iconName() -> String {
            "callout_icon_" + self.rawValue
        }
}

struct CalloutView: View {
    
    var type = CalloutType.warning
    var corners: [RectangleCorner] = []
    @State var content: String?
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 5) {
                Image(type.iconName())
                    .resizable()
                    .frame(size: CGSize(width: 16, height: 16))
                
                Text(content ?? "")
                    .font(Font.inter(size: 12))
                    .foregroundColor(Color.LL.Primary.salmonPrimary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal,16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.Theme.Accent.warning)
        .cornerRadius(corners, 8)
        .hidden((content == nil) ? true : false)
    }
}

struct CalloutView_Previews: PreviewProvider {
    static var previews: some View {
        CalloutView(content: "hello world")
    }
}
