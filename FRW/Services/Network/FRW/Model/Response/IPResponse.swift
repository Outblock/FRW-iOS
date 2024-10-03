//
//  IPResponse.swift
//  FRW
//
//  Created by cat on 2023/10/30.
//

import Foundation

struct IPResponse: Codable {
    let continent: String?
    let continentCode: String?
    let country: String?
    let countryCode: String?

    let regionName: String?
    let city: String?
    let district: String?
    let zip: String?
    let lat: Double?
    let lon: Double?
    let timezone: String?
    let currency: String?

    let isp: String?
    let org: String?
    let query: String?
}
