//
//  TxTemplateRequest.swift
//  Lilico
//
//  Created by Hao Fu on 29/9/2022.
//

import Foundation

struct TxTemplateRequest: Codable {
    let cadenceBase64: String
    let network: String
    
    enum CodingKeys: String, CodingKey {
        case cadenceBase64 = "cadence_base64"
        case network
    }
}
