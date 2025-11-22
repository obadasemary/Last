//
//  MockNewsFeedRepository.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 21.11.2025.
//

import Foundation
import Combine

final class MockNewsFeedRepository: NewsFeedRepositoryProtocol {
    
    var shouldFail = false
    
    func fetchNewsFeed(url: URL, onComplete: @escaping (Result<NewsFeedEntity, Error>) -> Void) {
        if shouldFail {
            onComplete(.failure(NetworkError.invalidResponse))
        } else {
            onComplete(.success(NewsFeedEntity.mock))
        }
    }
    
    func fetchNewsFeed(url: URL) -> AnyPublisher<NewsFeedEntity, Error> {
        if shouldFail {
            return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
        } else {
            return Just(NewsFeedEntity.mock)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchNewsFeed(url: URL) async throws -> NewsFeedEntity {
        if shouldFail {
            throw NetworkError.invalidResponse
        }
        return NewsFeedEntity.mock
    }
}
