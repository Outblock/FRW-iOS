//
//  DeviceInfoItem.swift
//  FRW
//
//  Created by cat on 2023/11/30.
//

import SwiftUI

struct DeviceInfoItem: View {
    var title: String
    var detail: String
    
    var body: some View {
        HStack {
            // Body1
            Text(title)
                .font(Font.inter(size: 16))
                .foregroundStyle(Color.Theme.Text.black8)
            Spacer()
            // Body1
            Text(detail)
                .font(Font.inter(size: 16))
                .multilineTextAlignment(.trailing)
                .foregroundStyle(Color.Theme.Text.black3)
        }
    }
}

#Preview {
    DeviceInfoItem(title: "application_tag".localized, detail: "Flow Core")
}
