//
//  StorageView.swift
//  FRW
//
//  Created by Antonio Bello on 11/6/24.
//

import SwiftUI

struct StorageUsageView: View {
    private let title: String?
    private var titleFont: Font?
    private var headerView: AnyView?
    private var footerView: AnyView?
    private let invertedVerticalOrder: Bool
    
    @Binding private var usage: String
    @Binding private var usageRatio: Double
    
    init(title: String? = nil, usage: Binding<String>, usageRatio: Binding<Double>, invertedVerticalOrder: Bool = false) {
        self.title = title
        self._usage = usage
        self._usageRatio = usageRatio
        self.invertedVerticalOrder = invertedVerticalOrder
    }
    
    var body: some View {
        VStack {
            if let headerView {
                headerView
            }
            
            if let title {
                Text(.init(title))
                    .font(self.titleFont)
                    .foregroundColor(Color.LL.Neutrals.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if invertedVerticalOrder {
                progressView()
            }

            HStack {
                Text(String(format: "%.2f%%", self.usageRatio * 100))
                    .font(.inter(size: 12, weight: .regular))
                    .foregroundColor(Color.LL.Neutrals.neutrals7)
                
                Spacer()
                
                Text(self.usage)
                    .font(.inter(size: 12, weight: .regular))
                    .foregroundColor(Color.LL.Neutrals.neutrals7)
            }
            .padding(.top, 5)

            if !invertedVerticalOrder {
                progressView()
            }
            
            if let footerView {
                footerView
            }
        }
    }
    
    private func progressView() -> some View {
        ProgressView(value: self.usageRatio, total: 1.0)
            .tint(Color.LL.Primary.salmonPrimary)
    }
    
    func titleFont(_ font: Font) -> Self {
        var view = self
        view.titleFont = font
        return view
    }
        
    func headerView<V: View>(_ header: V) -> Self {
        var view = self
        view.headerView = AnyView(header)
        return view
    }

    func footerView<V: View>(_ footer: V) -> Self {
        var view = self
        view.footerView = AnyView(footer)
        return view
    }
}

#Preview {
    let usage = Binding.constant("2KB / 98KB")
    let usageRatio = Binding.constant(2.01)
    StorageUsageView(title: "Storage", usage: usage, usageRatio: usageRatio)
        .padding(.horizontal, 20)
}
