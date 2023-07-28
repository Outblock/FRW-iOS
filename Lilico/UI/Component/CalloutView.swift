//
//  CalloutView.swift
//  Lilico
//
//  Created by cat on 2023/7/26.
//

import SwiftUI

enum CalloutType {
case tip,warning,failure
}

struct CalloutView: View {
    
    let icon = "callout_icon_warning"
    @State var content: String?
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 5) {
                Image(icon)
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
        .background(Color.LL.Primary.salmon5)
        .cornerRadius([.bottomLeading, .bottomTrailing], 8)
        .hidden((content == nil) ? true : false)
    }
}

struct CalloutView_Previews: PreviewProvider {
    static var previews: some View {
        CalloutView()
    }
}
