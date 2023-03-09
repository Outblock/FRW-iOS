//
//  EventLoop+Future.swift
//  Lilico
//
//  Created by Hao Fu on 30/4/2022.
//

import Combine
import Foundation
// import NIO

// extension EventLoopFuture {
//    func toFuture() -> Future<Value, Error> {
//        return Future { promise in
//            self.whenComplete { result in
//                switch result {
//                case let .success(response):
//                    promise(.success(response))
//                case let .failure(error):
//                    promise(.failure(error))
//                }
//            }
//        }
//    }
// }

extension Publisher {
    func asFuture() -> Future<Output, Failure> {
        var cancellable: AnyCancellable?
        return Future<Output, Failure> { promise in
            // cancellable is captured to assure the completion of the wrapped future
            cancellable = self.sink { completion in
                if case let .failure(error) = completion {
                    promise(.failure(error))
                }
            } receiveValue: { value in
                promise(.success(value))
            }
        }
    }
}
