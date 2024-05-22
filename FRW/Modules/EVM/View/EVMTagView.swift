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
            .kerning(0.144)
            .foregroundStyle(Color.white)
            .frame(width: 36, height: 16)
            .background(Color.Theme.evm)
            .cornerRadius(8)
    }
}

#Preview {
    EVMTagView()
}
