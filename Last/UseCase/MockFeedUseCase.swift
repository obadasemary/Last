//
//  MockFeedUseCase.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//


import Foundation
import Combine

class MockFeedUseCase: FeedUseCaseProtocol {
    
    private let result: Result<FeedEntity, Error>
    
    init(result: Result<FeedEntity, Error>) {
        self.result = result
    }
    
    func fetchFeed(
        url: URL,
        onComplete: @escaping (Result<FeedEntity, any Error>) -> Void
    ) {
        switch result {
        case .success(let response):
            onComplete(.success(response))
        case .failure(let error):
            onComplete(.failure(error))
        }
    }
    
    func fetchFeed(url: URL) -> AnyPublisher<FeedEntity, Error> {
        switch result {
        case .success(let response):
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchFeed(url: URL) async throws -> FeedEntity {
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}
