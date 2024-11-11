//
//  CurrencyListViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 31/10/2022.
//

import SwiftUI

class CurrencyListViewModel: ObservableObject {
    @Published
    var datas: [Currency] = Currency.allCases
    @Published
    var selectedCurrency: Currency = CurrencyCache.cache.currentCurrency

    func changeCurrencyAction(_ newCurrency: Currency) {
        if selectedCurrency == newCurrency {
            return
        }

        if newCurrency == .USD {
            CurrencyCache.cache.changeCurrency(currency: newCurrency, rate: 1)
            selectedCurrency = newCurrency
            return
        }

        let failedBlock = {
            DispatchQueue.main.async {
                HUD.dismissLoading()
                HUD.error(title: "request_failed".localized)
            }
        }

        HUD.loading()
        Task {
            do {
                let response: CurrencyRateResponse = try await Network
                    .request(FRWAPI.Utils.currencyRate(newCurrency))

                if let success = response.success, success != true {
                    failedBlock()
                    return
                }

                guard let latestRate = response.result, latestRate > 0 else {
                    failedBlock()
                    return
                }

                DispatchQueue.main.async {
                    HUD.dismissLoading()
                    CurrencyCache.cache.changeCurrency(currency: newCurrency, rate: latestRate)
                    self.selectedCurrency = newCurrency
                }
            } catch {
                failedBlock()
            }
        }
    }
}
