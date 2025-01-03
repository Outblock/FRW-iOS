//
//  OtherResponses.swift
//  Flow Wallet
//
//  Created by Selina on 26/9/2022.
//

import Foundation

// MARK: - SwapEstimateResponse.Route

extension SwapEstimateResponse {
    struct Route: Codable {
        // MARK: Lifecycle

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SwapEstimateResponse.Route.CodingKeys> =
                try decoder.container(keyedBy: SwapEstimateResponse.Route.CodingKeys.self)
            self.route = try container.decode(
                [String].self,
                forKey: SwapEstimateResponse.Route.CodingKeys.route
            )

            do {
                let routeAmountInString = try container.decode(
                    String.self,
                    forKey: SwapEstimateResponse.Route.CodingKeys.routeAmountIn
                )
                self.routeAmountIn = Double(routeAmountInString) ?? 0
            } catch {
                self.routeAmountIn = try container.decode(
                    Double.self,
                    forKey: SwapEstimateResponse.Route.CodingKeys.routeAmountIn
                )
            }

            do {
                let routeAmountOutString = try container.decode(
                    String.self,
                    forKey: SwapEstimateResponse.Route.CodingKeys.routeAmountOut
                )
                self.routeAmountOut = Double(routeAmountOutString) ?? 0
            } catch {
                self.routeAmountOut = try container.decode(
                    Double.self,
                    forKey: SwapEstimateResponse.Route.CodingKeys.routeAmountOut
                )
            }
        }

        // MARK: Internal

        let route: [String]
        let routeAmountIn: Double
        let routeAmountOut: Double
    }
}

// MARK: - SwapEstimateResponse

struct SwapEstimateResponse: Codable {
    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            let priceImpactString = try container.decode(String.self, forKey: .priceImpact)
            self.priceImpact = Double(priceImpactString) ?? 0
        } catch {
            self.priceImpact = try container.decode(Double.self, forKey: .priceImpact)
        }

        self.routes = try container.decode([SwapEstimateResponse.Route?].self, forKey: .routes)

        do {
            let tokenInAmountString = try container.decode(String.self, forKey: .tokenInAmount)
            self.tokenInAmount = Double(tokenInAmountString) ?? 0
        } catch {
            self.tokenInAmount = try container.decode(Double.self, forKey: .tokenInAmount)
        }

        do {
            let tokenOutAmountString = try container.decode(String.self, forKey: .tokenOutAmount)
            self.tokenOutAmount = Double(tokenOutAmountString) ?? 0
        } catch {
            self.tokenOutAmount = try container.decode(Double.self, forKey: .tokenOutAmount)
        }

        self.tokenInKey = try container.decode(String.self, forKey: .tokenInKey)
        self.tokenOutKey = try container.decode(String.self, forKey: .tokenOutKey)
    }

    // MARK: Internal

    let priceImpact: Double
    let routes: [SwapEstimateResponse.Route?]
    let tokenInAmount: Double
    let tokenInKey: String
    let tokenOutAmount: Double
    let tokenOutKey: String

    var tokenKeyFlatSplitPath: [String] {
        let array = routes.compactMap { route in
            route?.route
        }

        return array.flatMap { $0 }
    }

    var amountInSplit: [Decimal] {
        let array = routes.compactMap { route in
            route?.routeAmountIn
        }

        return array.compactMap { Decimal($0) }
    }

    var amountOutSplit: [Decimal] {
        let array = routes.compactMap { route in
            route?.routeAmountOut
        }

        return array.compactMap { Decimal($0) }
    }
}

// MARK: - CurrencyRateResponse

struct CurrencyRateResponse: Codable {
    let success: Bool?
    let result: Double?
    let date: String?
}
