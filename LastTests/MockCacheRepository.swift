//
//  MockCacheRepository.swift
//  LastTests
//
//  Created by Claude Code on 04.12.2025.
//

import Foundation
@testable import Last

final class MockCacheRepository: CacheRepositoryProtocol {
    
    var savedFeed: FeedEntity?
    var feedToReturn: FeedEntity?
    var shouldThrowError = false
    var saveFeedCallCount = 0
    var loadFeedCallCount = 0
    var clearCacheCallCount = 0

    func saveFeed(_ feed: FeedEntity) async throws {
        saveFeedCallCount += 1
        if shouldThrowError {
            throw NSError(domain: "MockCacheRepository", code: 1, userInfo: nil)
        }
        savedFeed = feed
    }

    func loadFeed() async throws -> FeedEntity? {
        loadFeedCallCount += 1
        if shouldThrowError {
            throw NSError(domain: "MockCacheRepository", code: 2, userInfo: nil)
        }
        return feedToReturn
    }

    func clearCache() async throws {
        clearCacheCallCount += 1
        if shouldThrowError {
            throw NSError(domain: "MockCacheRepository", code: 3, userInfo: nil)
        }
        savedFeed = nil
        feedToReturn = nil
    }
}
