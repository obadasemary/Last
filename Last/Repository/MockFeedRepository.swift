//
//  MockFeedRepository.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import Foundation

class MockFeedRepository: FeedRepositoryProtocol {
    func fetchFeed(url: URL) async throws -> FeedEntity {
        FeedEntity.mock
    }

    func fetchFeed(url: URL, onComplete: @escaping (Result<FeedEntity, Error>) -> Void) {
        onComplete(.success(FeedEntity.mock))
    }
}
