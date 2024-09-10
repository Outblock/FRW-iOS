//
//  ErrorStatus.swift
//  FRW
//
//  Created by cat on 2024/9/10.
//

import Foundation
import Moya

extension Error {
    func moyaCode() -> Int? {
        guard let error = self as? MoyaError else {
            return nil
        }
        switch error {
        case .statusCode(let response):
            return response.statusCode
        default:
            return nil
        }
    }
}
