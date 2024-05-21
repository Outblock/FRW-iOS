//
//  EVMTagView.swift
//  FRW
//
//  Created by cat on 2024/5/20.
//

import SwiftUI

struct EVMTagView: View {
    var body: some View {
        Text("EVM")
            .font(.inter(size: 9))
            .foregroundStyle(Color.Theme.Text.black)
            .frame(width: 36, height: 16)
            .background(Color.Theme.Accent.blue)
            .cornerRadius(8)
    }
}
