//
//  SVGCache.swift
//  Flow Wallet
//
//  Created by Selina on 24/8/2022.
//

import Alamofire
import Foundation
import Kingfisher

class SVGCache {
    static let cache = SVGCache()

    func getSVG(_ url: URL) async -> String? {
        let key = url.absoluteString.md5

        do {
            if let data = try ImageCache.default.diskStorage.value(forKey: key) {
                let string = String(data: data, encoding: .utf8)
                return string
            }

            return try await withCheckedThrowingContinuation { continuation in
                AF.download(url).responseData { response in
                    switch response.result {
                    case let .success(data):
                        do {
                            try ImageCache.default.diskStorage.store(value: data, forKey: key)
                            let string = String(data: data, encoding: .utf8)
                            continuation.resume(returning: string)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            return nil
        }
    }
}
