//
//  MockNewsFeedCacheRepository.swift
//  Last
//
//  Created by Claude Code on 10.12.2025.
//

import Foundation

final class MockNewsFeedCacheRepository: NewsFeedCacheRepositoryProtocol {

    var savedFeed: NewsFeedEntity?
    var shouldThrowOnSave = false
    var shouldThrowOnLoad = false
    var shouldThrowOnClear = false

    func saveNewsFeed(_ feed: NewsFeedEntity) async throws {
        if shouldThrowOnSave {
            throw NSError(domain: "MockError", code: -1, userInfo: nil)
        }
        savedFeed = feed
    }

    func loadNewsFeed() async throws -> NewsFeedEntity? {
        if shouldThrowOnLoad {
            throw NSError(domain: "MockError", code: -1, userInfo: nil)
        }
        return savedFeed
    }

    func clearCache() async throws {
        if shouldThrowOnClear {
            throw NSError(domain: "MockError", code: -1, userInfo: nil)
        }
        savedFeed = nil
    }
}
