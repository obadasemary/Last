//
//  MockFeedRepository.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import Foundation
import Combine

class MockFeedRepository: FeedRepositoryProtocol {
    
    func fetchFeed(url: URL, onComplete: @escaping (Result<FeedEntity, Error>) -> Void) {
        onComplete(.success(FeedEntity.mock))
    }

    func fetchFeed(url: URL) -> AnyPublisher<FeedEntity, Error> {
        Just(FeedEntity.mock)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchFeed(url: URL) async throws -> FeedEntity {
        FeedEntity.mock
    }
}
