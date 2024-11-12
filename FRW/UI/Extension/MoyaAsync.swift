//
//  MoyaAsync.swift
//  Flow Wallet
//
//  Created by Hao Fu on 2/1/22.
//

import Foundation
import Moya

public typealias AsyncTask = Task

public extension AsyncSequence where Element == Result<ProgressResponse, MoyaError> {
    func forEach(_ body: (Element) async throws -> Void) async throws {
        for try await element in self {
            try await body(element)
        }
    }
}

// MARK: - AsyncMoyaRequestWrapper

class AsyncMoyaRequestWrapper {
    // MARK: Lifecycle

    init(
        _ performRequest: @escaping (CheckedContinuation<Result<Response, MoyaError>, Never>)
            -> Moya.Cancellable?
    ) {
        self.performRequest = performRequest
    }

    // MARK: Internal

    var performRequest: (CheckedContinuation<Result<Response, MoyaError>, Never>) -> Moya
        .Cancellable?
    var cancellable: Moya.Cancellable?

    func perform(continuation: CheckedContinuation<Result<Response, MoyaError>, Never>) {
        cancellable = performRequest(continuation)
    }

    func cancel() {
        cancellable?.cancel()
    }
}

public extension MoyaProvider {
    /// Async request
    /// - Parameter target: Entity, with provides Moya.Target protocol
    /// - Returns: Result type with response and error
    func asyncRequest(_ target: Target) async -> Result<Response, MoyaError> {
        let asyncRequestWrapper = AsyncMoyaRequestWrapper { [weak self] continuation in
            guard let self = self else { return nil }
            return self.request(target) { result in
                switch result {
                case let .success(response):
                    continuation.resume(returning: .success(response))
                case let .failure(moyaError):
                    continuation.resume(returning: .failure(moyaError))
                }
            }
        }

        return await withTaskCancellationHandler(handler: {
            asyncRequestWrapper.cancel()
        }, operation: {
            await withCheckedContinuation { continuation in
                asyncRequestWrapper.perform(continuation: continuation)
            }
        })
    }

    /// Async request with progress using `AsyncStream`
    /// - Parameter target: Entity, with provides Moya.Target protocol
    /// - Returns: `AsyncStream<Result<ProgressResponse, MoyaError>>`  with Result type of progress and error
    func requestWithProgress(_ target: Target) async -> AsyncStream<Result<
        ProgressResponse,
        MoyaError
    >> {
        AsyncStream { stream in
            let cancelable = self.request(target) { progress in
                stream.yield(.success(progress))
            } completion: { result in
                switch result {
                case .success:
                    stream.finish()
                case let .failure(error):
                    stream.yield(.failure(error))
                    stream.finish()
                }
            }
            stream.onTermination = { @Sendable _ in
                cancelable.cancel()
            }
        }
    }
}
