//
//  LLSegmenControl.swift
//  Flow Reference Wallet
//
//  Created by cat on 2023/8/2.
//

import SwiftUI


struct LLSegmenControl: View {
    
    @State var titles: [String]
    @State var selectedIndex: Int = 0
    var onAction: ((Int)->())?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center ,spacing: 8) {
                ForEach(self.titles.indices, id: \.self) { index in
                    Button {
                        withAnimation {
                            self.selectedIndex = index
                        }
                        
                        if let onAction = self.onAction {
                            onAction(index)
                        }
                    } label: {
                        Text(titles[index])
                            .font(.inter(size: 12, weight: .w500))
                            .foregroundStyle(textColor(at: index) )
                        
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(buttonBG(at: index))
                    .cornerRadius(20)
                    .buttonStyle { config in
                        config.label
                    }
                    
                }
            }
        }
    }
    
    private func textColor(at index: Int) -> Color {
        isSelected(at: index) ? Color.LL.Secondary.navyWallet : Color.LL.Neutrals.text3
    }
    
    private func buttonBG(at index: Int) -> Color {
        isSelected(at: index)  ? .LL.Secondary.navy5 : .LL.Neutrals.neutrals6
    }
    
    private func isSelected(at index: Int) -> Bool {
        return self.selectedIndex == index;
    }
}



struct LLSegmenControl_Previews: PreviewProvider {
    
    fileprivate static var list:[String] = [
        "Hi","Hello","world","name","age",
    ]
    static var previews: some View {
        VStack {
            LLSegmenControl(titles: list) { idx in
                print("\(list[idx]) at \(idx)")
            }
        }
        
    }
}
