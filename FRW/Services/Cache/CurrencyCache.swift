//
//  CurrencyCache.swift
//  Flow Reference Wallet
//
//  Created by Selina on 28/10/2022.
//

import Foundation
import Combine
import SwiftUI

private let CacheUpdateInverval = TimeInterval(60)

class CurrencyCache: ObservableObject {
    static let cache = CurrencyCache()
    
    @Published var currentCurrency: Currency = LocalUserDefaults.shared.currentCurrency
    @Published var currentCurrencyRate: Double = LocalUserDefaults.shared.currentCurrencyRate
    
    private var lastUpdateTime: Date?
    private var isRefreshing = false
    
    init() {
        refreshRate()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshRate), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    var currencySymbol: String {
        return currentCurrency.symbol
    }
    
    func changeCurrency(currency: Currency, rate: Double) {
        let checkedRate = max(0, rate)
        LocalUserDefaults.shared.currentCurrency = currency
        LocalUserDefaults.shared.currentCurrencyRate = checkedRate
        
        currentCurrency = currency
        currentCurrencyRate = checkedRate
    }
}

extension CurrencyCache {
    @objc private func refreshRate() {
        if currentCurrency == .USD {
            if currentCurrencyRate != 1 {
                currentCurrencyRate = 1
            }
            
            return
        }
        
        let now = Date()
        if let lastUpdateTime = lastUpdateTime, abs(lastUpdateTime.timeIntervalSince(now)) < CacheUpdateInverval {
            return
        }
        
        isRefreshing = true
        let requestingCurrency = self.currentCurrency
        
        let failedBlock = {
            DispatchQueue.main.async {
                self.isRefreshing = false
            }
        }
        
        Task {
            do {
                let response: CurrencyRateResponse = try await Network.requestWithRawModel(FRWAPI.Utils.currencyRate(requestingCurrency))
                if self.currentCurrency != requestingCurrency {
                    // expired response
                    return
                }
                
                if let success = response.success, success != true {
                    failedBlock()
                    return
                }
                
                guard let latestRate = response.result, latestRate > 0 else {
                    failedBlock()
                    return
                }
                
                DispatchQueue.main.async {
                    self.isRefreshing = false
                    self.lastUpdateTime = Date()
                    self.currentCurrencyRate = latestRate
                    LocalUserDefaults.shared.currentCurrencyRate = latestRate
                }
            } catch {
                failedBlock()
            }
        }
    }
}
