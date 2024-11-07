//
//  StorageView.swift
//  FRW
//
//  Created by Antonio Bello on 11/6/24.
//

import SwiftUI

struct StorageUsageView: View {
    private let title: String
    private var titleFont: Font?
    
    @Binding private var usage: String
    @Binding private var usagePercentValue: Double
    
    init(title: String, usage: Binding<String>, usagePercentValue: Binding<Double>) {
        self.title = title
        self._usage = usage
        self._usagePercentValue = usagePercentValue
    }
    
    var body: some View {
        VStack {
            Text(.init(self.title))
                .font(self.titleFont)
                .foregroundColor(Color.LL.Neutrals.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text(String(format: "%.2f%%", self.usagePercentValue * 100))
                    .font(.inter(size: 12, weight: .regular))
                    .foregroundColor(Color.LL.Neutrals.neutrals7)
                
                Spacer()
                
                Text(self.usage)
                    .font(.inter(size: 12, weight: .regular))
                    .foregroundColor(Color.LL.Neutrals.neutrals7)
            }
            .padding(.top, 5)
            
            ProgressView(value: self.usagePercentValue, total: 1.0)
                .tint(Color.LL.Primary.salmonPrimary)
        }
    }
    
    func titleFont(_ font: Font) -> Self {
        var view = self
        view.titleFont = font
        return view
    }
}

#Preview {
    let usage = Binding.constant("2KB / 98KB")
    let usagePercentValue = Binding.constant(2.01)
    StorageUsageView(title: "Storage", usage: usage, usagePercentValue: usagePercentValue)
        .padding(.horizontal, 20)
}
