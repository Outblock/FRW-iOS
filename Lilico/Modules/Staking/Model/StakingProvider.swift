//
//  StakingProvider.swift
//  Lilico
//
//  Created by Selina on 30/11/2022.
//

import Foundation

struct StakingProvider: Codable {
    let description: String?
    let icon: String?
    let id: String
    let name: String
    let type: String
    let website: String?
    
    var isLilico: Bool {
        return name.lowercased() == "lilico"
    }
    
    var iconURL: URL? {
        return URL(string: icon ?? "")
    }
    
    var rate: Double {
        return isLilico ? StakingManager.shared.apy : StakingDefaultNormalApy
    }
    
    var apyYearPercentString: String {
        let num = (rate * 100).formatCurrencyString(digits: 2)
        return "\(num)%"
    }
    
    var delegatorId: Int? {
        return StakingManager.shared.delegatorIds[id]
    }
    
    var currentNode: StakingNode? {
        return StakingManager.shared.nodeInfos.first(where: { $0.nodeID == self.id })
    }
    
    var host: String {
        if let website, let url = URL(string: website) {
            return url.host ?? ""
        }
        return ""
    }
}
