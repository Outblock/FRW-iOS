//
//  TextCheckListView.swift
//  FRW
//
//  Created by cat on 2024/9/14.
//

import SwiftUI

struct TextCheckListView: View {
    var titles: [String]
    @Binding var allChecked: Bool

    @State var result: [String: Bool] = [:]

    var body: some View {
        VStack {
            ForEach(titles.indices, id: \.self) { index in
                TextCheckBox(text: titles[index]) { str, isSelected in
                    self.result[str] = isSelected
                    checkStatus()
                }
            }
        }
    }

    private func checkStatus() {
        guard result.count == titles.count else {
            allChecked = false
            return
        }
        let list = result.values.filter { !$0 }
        allChecked = list.isEmpty
    }
}

#Preview {
    TextCheckListView(titles: ["adb", "123", "44o"], allChecked: .constant(false))
}
