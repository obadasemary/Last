//
//  FeedUseCaseOfflineTests.swift
//  LastTests
//
//  Created by Claude Code on 04.12.2025.
//

import Testing
import Foundation
@testable import Last

@Suite(.serialized)
struct FeedUseCaseOfflineTests {

    // MARK: - Online Mode Tests

    @MainActor
    @Test("FeedUseCase online - Fetches from network and caches result")
    func online_FetchesFromNetworkAndCaches() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .success(FeedEntity.mock)
        let mockCacheRepository = MockCacheRepository()
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true

        let useCase = FeedUseCase(
            feedRepository: mockRepository,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!

        // When
        let result = try await useCase.fetchFeed(url: url)

        // Then
        #expect(result.info.count == FeedEntity.mock.info.count)
        #expect(mockRepository.asyncFetchFeedCallCount == 1)
        #expect(mockCacheRepository.saveFeedCallCount == 1)
        #expect(mockCacheRepository.savedFeed?.info.count == FeedEntity.mock.info.count)
        #expect(mockReachability.isNetworkAvailableCallCount == 1)
    }

    @MainActor
    @Test("FeedUseCase online - Network fails, falls back to cache")
    func online_NetworkFailsFallsBackToCache() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .failure(NetworkError.invalidResponse)
        let mockCacheRepository = MockCacheRepository()
        mockCacheRepository.feedToReturn = FeedEntity.mock
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true

        let useCase = FeedUseCase(
            feedRepository: mockRepository,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!

        // When
        let result = try await useCase.fetchFeed(url: url)

        // Then - Should return cached data despite network failure
        #expect(result.info.count == FeedEntity.mock.info.count)
        #expect(mockRepository.asyncFetchFeedCallCount == 1)
        #expect(mockCacheRepository.loadFeedCallCount == 1)
        #expect(mockCacheRepository.saveFeedCallCount == 0)
    }

    @MainActor
    @Test("FeedUseCase online - Network fails with no cache throws error")
    func online_NetworkFailsWithNoCacheThrowsError() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .failure(NetworkError.invalidResponse)
        let mockCacheRepository = MockCacheRepository()
        mockCacheRepository.feedToReturn = nil
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true

        let useCase = FeedUseCase(
            feedRepository: mockRepository,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!

        // When/Then
        do {
            let _ = try await useCase.fetchFeed(url: url)
            Issue.record("Expected to throw error")
        } catch let error as NetworkError {
            #expect(error == .invalidResponse)
            #expect(mockRepository.asyncFetchFeedCallCount == 1)
            #expect(mockCacheRepository.loadFeedCallCount == 1)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }

    // MARK: - Offline Mode Tests

    @MainActor
    @Test("FeedUseCase offline - Returns cached data")
    func offline_ReturnsCachedData() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .success(FeedEntity.mock)
        let mockCacheRepository = MockCacheRepository()
        mockCacheRepository.feedToReturn = FeedEntity.mock
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = false

        let useCase = FeedUseCase(
            feedRepository: mockRepository,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!

        // When
        let result = try await useCase.fetchFeed(url: url)

        // Then
        #expect(result.info.count == FeedEntity.mock.info.count)
        #expect(mockRepository.asyncFetchFeedCallCount == 0) // Should not call network
        #expect(mockCacheRepository.loadFeedCallCount == 1)
        #expect(mockReachability.isNetworkAvailableCallCount == 1)
    }

    @MainActor
    @Test("FeedUseCase offline - No cache throws specific error")
    func offline_NoCacheThrowsSpecificError() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .success(FeedEntity.mock)
        let mockCacheRepository = MockCacheRepository()
        mockCacheRepository.feedToReturn = nil
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = false

        let useCase = FeedUseCase(
            feedRepository: mockRepository,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!

        // When/Then
        do {
            let _ = try await useCase.fetchFeed(url: url)
            Issue.record("Expected to throw error")
        } catch let error as FeedUseCaseError {
            #expect(error == .noInternetAndNoCache)
            #expect(mockRepository.asyncFetchFeedCallCount == 0)
            #expect(mockCacheRepository.loadFeedCallCount == 1)
        } catch {
            Issue.record("Expected FeedUseCaseError but got \(error)")
        }
    }

    @MainActor
    @Test("FeedUseCase offline - Does not attempt network call")
    func offline_DoesNotAttemptNetworkCall() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .success(FeedEntity.mock)
        let mockCacheRepository = MockCacheRepository()
        mockCacheRepository.feedToReturn = FeedEntity.mock
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = false

        let useCase = FeedUseCase(
            feedRepository: mockRepository,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!

        // When
        let _ = try await useCase.fetchFeed(url: url)

        // Then - Verify network was never called
        #expect(mockRepository.asyncFetchFeedCallCount == 0)
        #expect(mockRepository.completionFetchFeedCallCount == 0)
        #expect(mockRepository.combineFetchFeedCallCount == 0)
    }

    // MARK: - Cache Priority Tests

    @MainActor
    @Test("FeedUseCase online - Fresh data preferred over cache")
    func online_FreshDataPreferredOverCache() async throws {
        // Given
        let freshFeed = FeedEntity(
            info: InfoResponse(count: 100, pages: 10),
            results: [
                CharactersResponse(
                    id: 999,
                    name: "Fresh Character",
                    species: "Fresh",
                    image: URL(string: "https://example.com/fresh.jpg")
                )
            ]
        )
        let cachedFeed = FeedEntity(
            info: InfoResponse(count: 50, pages: 5),
            results: [
                CharactersResponse(
                    id: 1,
                    name: "Cached Character",
                    species: "Cached",
                    image: URL(string: "https://example.com/cached.jpg")
                )
            ]
        )

        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .success(freshFeed)
        let mockCacheRepository = MockCacheRepository()
        mockCacheRepository.feedToReturn = cachedFeed
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true

        let useCase = FeedUseCase(
            feedRepository: mockRepository,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!

        // When
        let result = try await useCase.fetchFeed(url: url)

        // Then - Should return fresh data from network
        #expect(result.info.count == 100)
        #expect(result.results.first?.name == "Fresh Character")
        #expect(mockRepository.asyncFetchFeedCallCount == 1)
        #expect(mockCacheRepository.loadFeedCallCount == 0) // Should not load cache when network succeeds
    }

    // MARK: - Edge Cases

    @MainActor
    @Test("FeedUseCase offline - Error message is localized")
    func offline_ErrorMessageIsLocalized() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        let mockCacheRepository = MockCacheRepository()
        mockCacheRepository.feedToReturn = nil
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = false

        let useCase = FeedUseCase(
            feedRepository: mockRepository,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!

        // When/Then
        do {
            let _ = try await useCase.fetchFeed(url: url)
            Issue.record("Expected to throw error")
        } catch let error as FeedUseCaseError {
            let errorDescription = error.errorDescription
            #expect(errorDescription != nil)
            #expect(errorDescription?.contains("internet") == true || errorDescription?.contains("cache") == true)
        } catch {
            Issue.record("Expected FeedUseCaseError but got \(error)")
        }
    }

    @MainActor
    @Test("FeedUseCase - Multiple offline requests use cache efficiently")
    func offline_MultipleRequestsUseCacheEfficiently() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        let mockCacheRepository = MockCacheRepository()
        mockCacheRepository.feedToReturn = FeedEntity.mock
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = false

        let useCase = FeedUseCase(
            feedRepository: mockRepository,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!

        // When - Make multiple requests
        let result1 = try await useCase.fetchFeed(url: url)
        let result2 = try await useCase.fetchFeed(url: url)
        let result3 = try await useCase.fetchFeed(url: url)

        // Then
        #expect(result1.info.count == FeedEntity.mock.info.count)
        #expect(result2.info.count == FeedEntity.mock.info.count)
        #expect(result3.info.count == FeedEntity.mock.info.count)
        #expect(mockRepository.asyncFetchFeedCallCount == 0)
        #expect(mockCacheRepository.loadFeedCallCount == 3)
    }
}
