//
//  Currency.swift
//  Flow Wallet
//
//  Created by Selina on 28/10/2022.
//

import Foundation

enum Currency: String, CaseIterable {
    case USD
    case EUR
    case CNY
    case AUD
    case CAD
    case KRW
    case HKD
    case SGD
    case RUB
    case JPY
    case TWD
    case CHF
    case MXN
    case BRL

    // MARK: Internal

    var symbol: String {
        switch self {
        case .USD:
            return "$"
        case .CNY:
            return "¥"
        case .AUD:
            return "$"
        case .EUR:
            return "€"
        case .CHF:
            return "Fr"
        case .KRW:
            return "₩"
        case .RUB:
            return "₽"
        case .JPY:
            return "¥"
        case .TWD:
            return "$"
        case .MXN:
            return "$"
        case .SGD:
            return "$"
        case .CAD:
            return "$"
        case .HKD:
            return "$"
        case .BRL:
            return "$"
        }
    }

    var name: String {
        switch self {
        case .USD:
            return "United States Dollar"
        case .EUR:
            return "Euro"
        case .CNY:
            return "Chinese Yuan"
        case .AUD:
            return "Australian Dollar "
        case .CHF:
            return "Swiss Franc"
        case .KRW:
            return "South Korean Won"
        case .SGD:
            return "Singapore Dollar"
        case .RUB:
            return "Russian Ruble"
        case .JPY:
            return "Japanese Yen"
        case .TWD:
            return "New Taiwan Dollar"
        case .MXN:
            return "Mexican Peso"
        case .CAD:
            return "Canadian Dollar"
        case .HKD:
            return "Hong Kong Dollar"
        case .BRL:
            return "Brazilian Real"
        }
    }

    var flag: String {
        switch self {
        case .USD:
            return "🇺🇸"
        case .EUR:
            return "🇪🇺"
        case .CNY:
            return "🇨🇳"
        case .AUD:
            return "🇦🇺"
        case .CAD:
            return "🇨🇦"
        case .KRW:
            return "🇰🇷"
        case .HKD:
            return "🇭🇰"
        case .SGD:
            return "🇸🇬"
        case .RUB:
            return "🇷🇺"
        case .JPY:
            return "🇯🇵"
        case .TWD:
            return "🇹🇼"
        case .CHF:
            return "🇨🇭"
        case .MXN:
            return "🇲🇽"
        case .BRL:
            return "🇧🇷"
        }
    }
}
