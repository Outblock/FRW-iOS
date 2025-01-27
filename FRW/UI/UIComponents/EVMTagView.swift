//
//  EVMTagView.swift
//  FRW
//
//  Created by Marty Ulrich on 1/27/25.
//

import SwiftUI
import Theme

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
