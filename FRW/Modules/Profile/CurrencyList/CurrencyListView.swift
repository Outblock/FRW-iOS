//
//  CurrencyListView.swift
//  Flow Reference Wallet
//
//  Created by Selina on 31/10/2022.
//

import SwiftUI

struct CurrencyListView: RouteableView {
    @StateObject private var vm = CurrencyListViewModel()
    
    var title: String {
        return "currency".localized
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(vm.datas, id: \.self) { currency in
                    createCurrencyListCell(currency: currency, selected: vm.selectedCurrency == currency)
                    
                    if currency != vm.datas.last {
                        Divider().background(Color.LL.Neutrals.background)
                    }
                }
            }
            .padding(.horizontal, 16)
            .roundedBg()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 18)
        }
        .backgroundFill(Color.LL.Neutrals.background)
        .applyRouteable(self)
    }
    
    func createCurrencyListCell(currency: Currency, selected: Bool) -> some View {
        Button {
            vm.changeCurrencyAction(currency)
        } label: {
            HStack {
                Text(currency.flag)
                    .font(.inter(size: 16, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text)
                
                Text(currency.rawValue)
                    .font(.inter(size: 16, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text)
                
                Spacer()
                
                Image(systemName: .checkmarkSelected)
                    .foregroundColor(Color.LL.Success.success2)
                    .visibility(selected ? .visible : .gone)
            }
        }
        .frame(height: 50)
    }
}
