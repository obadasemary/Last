//
//  NewsFeedCacheRepository.swift
//  Last
//
//  Created by Claude Code on 10.12.2025.
//

import Foundation
import SwiftData

protocol NewsFeedCacheRepositoryProtocol: Sendable {
    func saveNewsFeed(_ feed: NewsFeedEntity) async throws
    func loadNewsFeed() async throws -> NewsFeedEntity?
    func clearCache() async throws
}

final class NewsFeedCacheRepository: NewsFeedCacheRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveNewsFeed(_ feed: NewsFeedEntity) async throws {
        await MainActor.run {
            // Delete existing cached news feed
            let descriptor = FetchDescriptor<CachedNewsFeedEntity>()
            if let existingFeeds = try? modelContext.fetch(descriptor) {
                existingFeeds.forEach { modelContext.delete($0) }
            }

            // Insert new feed
            let cachedFeed = CachedNewsFeedEntity(from: feed)
            modelContext.insert(cachedFeed)

            // Save context
            try? modelContext.save()
        }
    }

    func loadNewsFeed() async throws -> NewsFeedEntity? {
        await MainActor.run {
            let descriptor = FetchDescriptor<CachedNewsFeedEntity>()
            guard let cachedFeed = try? modelContext.fetch(descriptor).first else {
                return nil
            }
            return cachedFeed.toNewsFeedEntity()
        }
    }

    func clearCache() async throws {
        await MainActor.run {
            let descriptor = FetchDescriptor<CachedNewsFeedEntity>()
            if let existingFeeds = try? modelContext.fetch(descriptor) {
                existingFeeds.forEach { modelContext.delete($0) }
            }
            try? modelContext.save()
        }
    }
}
