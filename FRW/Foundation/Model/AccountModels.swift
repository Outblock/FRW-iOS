//
//  AccountModels.swift
//  FRW
//
//  Created by Antonio Bello on 11/7/24.
//

import Foundation
import Flow

extension Flow {
    struct AccountInfo: Decodable {
        //public let address: Flow.Address
        public let balance: Decimal
        public let availableBalance: Decimal
        public let storageUsed: UInt64
        public let storageCapacity: UInt64
        public let storageFlow: Decimal
    }
}
