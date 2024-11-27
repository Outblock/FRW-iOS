//
//  WalletResponses.swift
//  Flow Wallet
//
//  Created by Selina on 23/6/2022.
//

import Foundation

// MARK: - Coin Rate

extension CryptoSummaryResponse {
    struct Allowance: Codable {
        let cost: Double
        let remaining: Double
    }

    struct Result: Codable {
        let price: Price
    }

    struct Price: Codable {
        let last: Double
        let low: Double?
        let high: Double?
        let change: Change
    }

    struct Change: Codable {
        let absolute: Double?
        let percentage: Double
    }

    struct AddPrice: Codable {
        let contractAddress: String
        let contractName: String
        var rateToFLOW: Double = 0
        var rateToUSD: Double = 0
        var symbol: String?
        var evmAddress: String?
    }
}

// MARK: - CryptoSummaryResponse

struct CryptoSummaryResponse: Codable {
    let result: CryptoSummaryResponse.Result

    static func createFixedRateResponse(fixedRate: Decimal) -> CryptoSummaryResponse {
//        let allowance = CryptoSummaryResponse.Allowance(cost: 0, remaining: 0)
        let change = Change(absolute: 0, percentage: 0)
        let price = Price(
            last: fixedRate.doubleValue,
            low: fixedRate.doubleValue,
            high: fixedRate.doubleValue,
            change: change
        )
        let result = CryptoSummaryResponse.Result(price: price)
        return CryptoSummaryResponse(result: result)
    }

    func getLastRate() -> Double {
        result.price.last
    }

    func getChangePercentage() -> Double {
        result.price.change.percentage
    }
}

// MARK: - CryptoHistoryResponse

struct CryptoHistoryResponse: Codable {
//    let allowance: CryptoSummaryResponse.Allowance
    let result: [String: [[Double]]]

    func parseMarketQuoteData(
        rangeType: TokenDetailView
            .ChartRangeType
    ) -> [TokenDetailView.Quote] {
        guard let array = result["\(rangeType.frequency.rawValue)"] else {
            return []
        }

        var quotes = [TokenDetailView.Quote]()
        for l in array {
            let quote = TokenDetailView.Quote(
                closeTime: l[0],
                openPrice: l[1],
                highPrice: l[2],
                lowPrice: l[3],
                closePrice: l[4],
                volume: l[5],
                quoteVolume: l[6]
            )
            quotes.append(quote)
        }

        return quotes
    }
}
