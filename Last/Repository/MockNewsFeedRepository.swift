//
//  MockNewsFeedRepository.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 21.11.2025.
//

import Foundation

final class MockNewsFeedRepository: NewsFeedRepositoryProtocol {

    var shouldFail = false
    var isFromRemote = true

    func fetchNewsFeed(url: URL) async throws -> (NewsFeedEntity, isFromRemote: Bool) {
        if shouldFail {
            throw NetworkError.invalidResponse
        }
        return (NewsFeedEntity.mock, isFromRemote: isFromRemote)
    }
}
