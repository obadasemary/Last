//
//  CacheRepository.swift
//  Last
//
//  Created by Claude Code on 04.12.2025.
//

import Foundation
import SwiftData

protocol CacheRepositoryProtocol: Sendable {
    func saveFeed(_ feed: FeedEntity) async throws
    func loadFeed() async throws -> FeedEntity?
    func clearCache() async throws
}

final class CacheRepository: CacheRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveFeed(_ feed: FeedEntity) async throws {
        await MainActor.run {
            // Delete existing cached feed
            let descriptor = FetchDescriptor<CachedFeedEntity>()
            if let existingFeeds = try? modelContext.fetch(descriptor) {
                existingFeeds.forEach { modelContext.delete($0) }
            }

            // Insert new feed
            let cachedFeed = CachedFeedEntity(from: feed)
            modelContext.insert(cachedFeed)

            // Save context
            try? modelContext.save()
        }
    }

    func loadFeed() async throws -> FeedEntity? {
        await MainActor.run {
            let descriptor = FetchDescriptor<CachedFeedEntity>()
            guard let cachedFeed = try? modelContext.fetch(descriptor).first else {
                return nil
            }
            return cachedFeed.toFeedEntity()
        }
    }

    func clearCache() async throws {
        await MainActor.run {
            let descriptor = FetchDescriptor<CachedFeedEntity>()
            if let existingFeeds = try? modelContext.fetch(descriptor) {
                existingFeeds.forEach { modelContext.delete($0) }
            }
            try? modelContext.save()
        }
    }
}
