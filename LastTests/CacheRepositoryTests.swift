//
//  CacheRepositoryTests.swift
//  LastTests
//
//  Created by Claude Code on 04.12.2025.
//

import Testing
import Foundation
import SwiftData
@testable import Last

@Suite(.serialized)
struct CacheRepositoryTests {
    
    // MARK: - Save Feed Tests
    
    @MainActor
    @Test("CacheRepository saveFeed - Successfully saves feed")
    func saveFeed_WithValidFeed_SavesSuccessfully() async throws {
        // Given
        let container = try createInMemoryContainer()
        let repository = CacheRepository(modelContext: container.mainContext)
        let feed = FeedEntity.mock
        
        // When
        try await repository.saveFeed(feed)
        
        // Then
        let descriptor = FetchDescriptor<CachedFeedEntity>()
        let cachedFeeds = try container.mainContext.fetch(descriptor)
        
        #expect(cachedFeeds.count == 1)
        #expect(cachedFeeds.first?.count == feed.info.count)
        #expect(cachedFeeds.first?.pages == feed.info.pages)
        #expect(cachedFeeds.first?.characters.count == feed.results.count)
    }
    
    @MainActor
    @Test("CacheRepository saveFeed - Replaces existing feed")
    func saveFeed_WithExistingFeed_ReplacesOldFeed() async throws {
        // Given
        let container = try createInMemoryContainer()
        let repository = CacheRepository(modelContext: container.mainContext)
        let oldFeed = FeedEntity.mock
        let newFeed = FeedEntity(
            info: InfoResponse(count: 100, pages: 10),
            results: [
                CharactersResponse(
                    id: 999,
                    name: "New Character",
                    species: "Robot",
                    image: URL(string: "https://example.com/new.jpg"),
                    video: nil
                )
            ]
        )
        
        // When
        try await repository.saveFeed(oldFeed)
        try await repository.saveFeed(newFeed)
        
        // Then
        let descriptor = FetchDescriptor<CachedFeedEntity>()
        let cachedFeeds = try container.mainContext.fetch(descriptor)
        
        #expect(cachedFeeds.count == 1)
        #expect(cachedFeeds.first?.count == newFeed.info.count)
        #expect(cachedFeeds.first?.pages == newFeed.info.pages)
        #expect(cachedFeeds.first?.characters.count == 1)
        #expect(cachedFeeds.first?.characters.first?.name == "New Character")
    }
    
    // MARK: - Load Feed Tests
    
    @MainActor
    @Test("CacheRepository loadFeed - Returns nil when no cache exists")
    func loadFeed_WithNoCache_ReturnsNil() async throws {
        // Given
        let container = try createInMemoryContainer()
        let repository = CacheRepository(modelContext: container.mainContext)
        
        // When
        let result = try await repository.loadFeed()
        
        // Then
        #expect(result == nil)
    }
    
    @MainActor
    @Test("CacheRepository loadFeed - Returns cached feed")
    func loadFeed_WithCachedFeed_ReturnsFeed() async throws {
        // Given
        let container = try createInMemoryContainer()
        let repository = CacheRepository(modelContext: container.mainContext)
        let feed = FeedEntity.mock
        
        try await repository.saveFeed(feed)
        
        // When
        let result = try await repository.loadFeed()
        
        // Then
        #expect(result != nil)
        #expect(result?.info.count == feed.info.count)
        #expect(result?.info.pages == feed.info.pages)
        #expect(result?.results.count == feed.results.count)
        
        // Verify all characters are present (order doesn't matter)
        let resultIds = Set(result?.results.map { $0.id } ?? [])
        let expectedIds = Set(feed.results.map { $0.id })
        #expect(resultIds == expectedIds)
    }
    
    @MainActor
    @Test("CacheRepository loadFeed - Preserves all character data")
    func loadFeed_WithCachedFeed_PreservesAllData() async throws {
        // Given
        let container = try createInMemoryContainer()
        let repository = CacheRepository(modelContext: container.mainContext)
        let feed = FeedEntity(
            info: InfoResponse(count: 2, pages: 1),
            results: [
                CharactersResponse(
                    id: 1,
                    name: "Rick",
                    species: "Human",
                    image: URL(string: "https://example.com/rick.jpg"),
                    video: nil
                ),
                CharactersResponse(
                    id: 2,
                    name: "Morty",
                    species: "Human",
                    image: URL(string: "https://example.com/morty.jpg"),
                    video: nil
                )
            ]
        )
        
        try await repository.saveFeed(feed)
        
        // When
        let result = try await repository.loadFeed()
        
        // Then
        #expect(result != nil)
        #expect(result?.results.count == 2)
        
        let rick = result?.results.first { $0.id == 1 }
        #expect(rick?.name == "Rick")
        #expect(rick?.species == "Human")
        #expect(rick?.image?.absoluteString == "https://example.com/rick.jpg")
        
        let morty = result?.results.first { $0.id == 2 }
        #expect(morty?.name == "Morty")
        #expect(morty?.species == "Human")
        #expect(morty?.image?.absoluteString == "https://example.com/morty.jpg")
    }
    
    // MARK: - Clear Cache Tests
    
    @MainActor
    @Test("CacheRepository clearCache - Removes all cached data")
    func clearCache_WithCachedData_RemovesAllData() async throws {
        // Given
        let container = try createInMemoryContainer()
        let repository = CacheRepository(modelContext: container.mainContext)
        let feed = FeedEntity.mock
        
        try await repository.saveFeed(feed)
        
        // Verify data was saved
        var descriptor = FetchDescriptor<CachedFeedEntity>()
        var cachedFeeds = try container.mainContext.fetch(descriptor)
        #expect(cachedFeeds.count == 1)
        
        // When
        try await repository.clearCache()
        
        // Then
        descriptor = FetchDescriptor<CachedFeedEntity>()
        cachedFeeds = try container.mainContext.fetch(descriptor)
        #expect(cachedFeeds.count == 0)
        
        let loadedFeed = try await repository.loadFeed()
        #expect(loadedFeed == nil)
    }
    
    @MainActor
    @Test("CacheRepository clearCache - No error when no data exists")
    func clearCache_WithNoData_NoError() async throws {
        // Given
        let container = try createInMemoryContainer()
        let repository = CacheRepository(modelContext: container.mainContext)
        
        // When/Then - Should not throw
        try await repository.clearCache()
        
        // Verify still empty
        let descriptor = FetchDescriptor<CachedFeedEntity>()
        let cachedFeeds = try container.mainContext.fetch(descriptor)
        #expect(cachedFeeds.count == 0)
    }
    
    // MARK: - Helper Methods
    
    @MainActor
    private func createInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([
            CachedFeedEntity.self,
            CachedCharacter.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }
}
