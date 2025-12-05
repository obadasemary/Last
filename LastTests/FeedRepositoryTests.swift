//
//  FeedRepositoryTests.swift
//  LastTests
//
//  Created by Abdelrahman Mohamed on 06.11.2025.
//

import Testing
import Foundation
import Combine
@testable import Last

@Suite(.serialized)
struct FeedRepositoryTests {

    // MARK: - Test Helpers

    @MainActor
    private func makeSUT(
        networkResult: Result<FeedEntity, Error> = .success(FeedEntity.mock),
        isOnline: Bool = true,
        cachedFeed: FeedEntity? = nil
    ) -> (sut: FeedRepository, mocks: (network: MockNetworkService, cache: MockCacheRepository, reachability: MockNetworkReachability)) {
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = networkResult

        let mockCacheRepository = MockCacheRepository()
        mockCacheRepository.feedToReturn = cachedFeed

        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = isOnline

        let repository = FeedRepository(
            networkService: mockNetworkService,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )

        return (repository, (mockNetworkService, mockCacheRepository, mockReachability))
    }

    // MARK: - Async/Await Tests
    
    @MainActor
    @Test("FeedRepository async fetchFeed - Success with network")
    func asyncFetchFeed_WithSuccess_ReturnsEntity() async throws {
        // Given
        let (repository, (mockNetworkService, mockCacheRepository, _)) = makeSUT(
            networkResult: .success(FeedEntity.mock),
            isOnline: true
        )
        let url = URL(string: "https://test.com")!

        // When
        let result = try await repository.fetchFeed(url: url)

        // Then
        #expect(result.info.count == FeedEntity.mock.info.count)
        #expect(result.info.pages == FeedEntity.mock.info.pages)
        #expect(result.results.count == FeedEntity.mock.results.count)
        #expect(mockNetworkService.executeCallCount == 1)
        #expect(mockCacheRepository.saveFeedCallCount == 1)
    }
    
    @MainActor
    @Test("FeedRepository async fetchFeed - Network Error")
    func asyncFetchFeed_WithNetworkError_ThrowsError() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = .failure(NetworkError.invalidResponse)
        let mockCacheRepository = MockCacheRepository()
        let mockReachability = MockNetworkReachability()
        let repository = FeedRepository(
            networkService: mockNetworkService,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!
        
        // When/Then
        do {
            let _ = try await repository.fetchFeed(url: url)
            Issue.record("Expected to throw error")
        } catch let error as NetworkError {
            #expect(error == .invalidResponse)
            #expect(mockNetworkService.executeCallCount == 1)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }
    
    @MainActor
    @Test("FeedRepository async fetchFeed - Decoding Error")
    func asyncFetchFeed_WithDecodingError_ThrowsError() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = .failure(NetworkError.decodingError)
        let mockCacheRepository = MockCacheRepository()
        let mockReachability = MockNetworkReachability()
        let repository = FeedRepository(
            networkService: mockNetworkService,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!
        
        // When/Then
        do {
            let _ = try await repository.fetchFeed(url: url)
            Issue.record("Expected to throw error")
        } catch let error as NetworkError {
            #expect(error == .decodingError)
            #expect(mockNetworkService.executeCallCount == 1)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }
    
    // MARK: - Completion Handler Tests
    
    @MainActor
    @Test("FeedRepository completion fetchFeed - Success")
    func completionFetchFeed_WithSuccess_ReturnsEntity() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = .success(FeedEntity.mock)
        let mockCacheRepository = MockCacheRepository()
        let mockReachability = MockNetworkReachability()
        let repository = FeedRepository(
            networkService: mockNetworkService,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!
        
        // When
        let result: FeedEntity = try await withCheckedThrowingContinuation { continuation in
            repository.fetchFeed(url: url) { result in
                continuation.resume(with: result)
            }
        }
        
        // Then
        #expect(result.info.count == FeedEntity.mock.info.count)
        #expect(result.info.pages == FeedEntity.mock.info.pages)
        #expect(result.results.count == FeedEntity.mock.results.count)
        // Completion method now delegates to async method
        #expect(mockNetworkService.executeCallCount == 1)
    }
    
    @MainActor
    @Test("FeedRepository completion fetchFeed - Network Error")
    func completionFetchFeed_WithNetworkError_ReturnsFailure() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = .failure(NetworkError.invalidResponse)
        let mockCacheRepository = MockCacheRepository()
        let mockReachability = MockNetworkReachability()
        let repository = FeedRepository(
            networkService: mockNetworkService,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!
        
        // When/Then
        do {
            let _: FeedEntity = try await withCheckedThrowingContinuation { continuation in
                repository.fetchFeed(url: url) { result in
                    continuation.resume(with: result)
                }
            }
            Issue.record("Expected to throw error")
        } catch let error as NetworkError {
            #expect(error == .invalidResponse)
            // Completion method now delegates to async method
            #expect(mockNetworkService.executeCallCount == 1)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }
    
    @MainActor
    @Test("FeedRepository completion fetchFeed - Decoding Error")
    func completionFetchFeed_WithDecodingError_ReturnsFailure() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = .failure(NetworkError.decodingError)
        let mockCacheRepository = MockCacheRepository()
        let mockReachability = MockNetworkReachability()
        let repository = FeedRepository(
            networkService: mockNetworkService,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!
        
        // When/Then
        do {
            let _: FeedEntity = try await withCheckedThrowingContinuation { continuation in
                repository.fetchFeed(url: url) { result in
                    continuation.resume(with: result)
                }
            }
            Issue.record("Expected to throw error")
        } catch let error as NetworkError {
            #expect(error == .decodingError)
            // Completion method now delegates to async method
            #expect(mockNetworkService.executeCallCount == 1)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }
    
    // MARK: - Combine Tests
    
    @MainActor
    @Test("FeedRepository Combine fetchFeed - Success")
    func combineFetchFeed_WithSuccess_PublishesEntity() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = .success(FeedEntity.mock)
        let mockCacheRepository = MockCacheRepository()
        let mockReachability = MockNetworkReachability()
        let repository = FeedRepository(
            networkService: mockNetworkService,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!
        
        // When
        let publisher: AnyPublisher<FeedEntity, Error> = repository.fetchFeed(url: url)
        let result: FeedEntity = try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = publisher.sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                },
                receiveValue: { value in
                    continuation.resume(returning: value)
                }
            )
        }
        
        // Then
        #expect(result.info.count == FeedEntity.mock.info.count)
        #expect(result.info.pages == FeedEntity.mock.info.pages)
        #expect(result.results.count == FeedEntity.mock.results.count)
        // Combine method now delegates to async method
        #expect(mockNetworkService.executeCallCount == 1)
    }
    
    @MainActor
    @Test("FeedRepository Combine fetchFeed - Network Error")
    func combineFetchFeed_WithNetworkError_PublishesError() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = .failure(NetworkError.invalidResponse)
        let mockCacheRepository = MockCacheRepository()
        let mockReachability = MockNetworkReachability()
        let repository = FeedRepository(
            networkService: mockNetworkService,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!
        
        // When/Then
        let publisher: AnyPublisher<FeedEntity, Error> = repository.fetchFeed(url: url)
        do {
            let _: FeedEntity = try await withCheckedThrowingContinuation { continuation in
                var cancellable: AnyCancellable?
                cancellable = publisher.sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
            }
            Issue.record("Expected to throw error")
        } catch let error as NetworkError {
            #expect(error == .invalidResponse)
            // Combine method now delegates to async method
            #expect(mockNetworkService.executeCallCount == 1)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }
    
    @MainActor
    @Test("FeedRepository Combine fetchFeed - Decoding Error")
    func combineFetchFeed_WithDecodingError_PublishesError() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = .failure(NetworkError.decodingError)
        let mockCacheRepository = MockCacheRepository()
        let mockReachability = MockNetworkReachability()
        let repository = FeedRepository(
            networkService: mockNetworkService,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!
        
        // When/Then
        let publisher: AnyPublisher<FeedEntity, Error> = repository.fetchFeed(url: url)
        do {
            let _: FeedEntity = try await withCheckedThrowingContinuation { continuation in
                var cancellable: AnyCancellable?
                cancellable = publisher.sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
            }
            Issue.record("Expected to throw error")
        } catch let error as NetworkError {
            #expect(error == .decodingError)
            // Combine method now delegates to async method
            #expect(mockNetworkService.executeCallCount == 1)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }
    
    // MARK: - Async Wrapper Tests (Learning)
    
    @MainActor
    @Test("FeedRepository fetchFeedFromCompletion - Success")
    func fetchFeedFromCompletion_WithSuccess_ReturnsEntity() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = .success(FeedEntity.mock)
        let mockCacheRepository = MockCacheRepository()
        let mockReachability = MockNetworkReachability()
        let repository = FeedRepository(
            networkService: mockNetworkService,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!
        
        // When
        let result = try await repository.fetchFeedFromCompletion(url: url)
        
        // Then
        #expect(result.info.count == FeedEntity.mock.info.count)
        #expect(result.info.pages == FeedEntity.mock.info.pages)
        #expect(result.results.count == FeedEntity.mock.results.count)
        // Completion method now delegates to async method
        #expect(mockNetworkService.executeCallCount == 1)
    }
    
    @MainActor
    @Test("FeedRepository fetchFeedFromCompletion - Network Error")
    func fetchFeedFromCompletion_WithNetworkError_ThrowsError() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = .failure(NetworkError.invalidResponse)
        let mockCacheRepository = MockCacheRepository()
        let mockReachability = MockNetworkReachability()
        let repository = FeedRepository(
            networkService: mockNetworkService,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!
        
        // When/Then
        do {
            let _ = try await repository.fetchFeedFromCompletion(url: url)
            Issue.record("Expected to throw error")
        } catch let error as NetworkError {
            #expect(error == .invalidResponse)
            // Completion method now delegates to async method
            #expect(mockNetworkService.executeCallCount == 1)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }
    
    @MainActor
    @Test("FeedRepository fetchFeedFromCombine - Success")
    func fetchFeedFromCombine_WithSuccess_ReturnsEntity() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = .success(FeedEntity.mock)
        let mockCacheRepository = MockCacheRepository()
        let mockReachability = MockNetworkReachability()
        let repository = FeedRepository(
            networkService: mockNetworkService,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!
        
        // When
        let result = try await repository.fetchFeedFromCombine(url: url)
        
        // Then
        #expect(result.info.count == FeedEntity.mock.info.count)
        #expect(result.info.pages == FeedEntity.mock.info.pages)
        #expect(result.results.count == FeedEntity.mock.results.count)
        // Combine method now delegates to async method
        #expect(mockNetworkService.executeCallCount == 1)
    }
    
    @MainActor
    @Test("FeedRepository fetchFeedFromCombine - Network Error")
    func fetchFeedFromCombine_WithNetworkError_ThrowsError() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = .failure(NetworkError.invalidResponse)
        let mockCacheRepository = MockCacheRepository()
        let mockReachability = MockNetworkReachability()
        let repository = FeedRepository(
            networkService: mockNetworkService,
            cacheRepository: mockCacheRepository,
            networkReachability: mockReachability
        )
        let url = URL(string: "https://test.com")!
        
        // When/Then
        do {
            let _ = try await repository.fetchFeedFromCombine(url: url)
            Issue.record("Expected to throw error")
        } catch let error as NetworkError {
            #expect(error == .invalidResponse)
            // Combine method now delegates to async method
            #expect(mockNetworkService.executeCallCount == 1)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }

    // MARK: - Offline Scenario Tests

    @MainActor
    @Test("FeedRepository - Online, success, caches result")
    func online_NetworkSuccess_CachesResult() async throws {
        // Given
        let (repository, (mockNetwork, mockCache, mockReachability)) = makeSUT(
            networkResult: .success(FeedEntity.mock),
            isOnline: true
        )
        let url = URL(string: "https://test.com")!

        // When
        let result = try await repository.fetchFeed(url: url)

        // Then
        #expect(result.info.count == FeedEntity.mock.info.count)
        #expect(mockNetwork.executeCallCount == 1)
        #expect(mockReachability.isNetworkAvailableCallCount == 1)
        #expect(mockCache.saveFeedCallCount == 1)
        #expect(mockCache.savedFeed?.info.count == FeedEntity.mock.info.count)
    }

    @MainActor
    @Test("FeedRepository - Online, network fails, cache available, returns cache")
    func online_NetworkFails_CacheAvailable_ReturnsCache() async throws {
        // Given
        let (repository, (mockNetwork, mockCache, mockReachability)) = makeSUT(
            networkResult: .failure(NetworkError.invalidResponse),
            isOnline: true,
            cachedFeed: FeedEntity.mock
        )
        let url = URL(string: "https://test.com")!

        // When
        let result = try await repository.fetchFeed(url: url)

        // Then - Should return cached data
        #expect(result.info.count == FeedEntity.mock.info.count)
        #expect(mockNetwork.executeCallCount == 1)
        #expect(mockReachability.isNetworkAvailableCallCount == 1)
        #expect(mockCache.loadFeedCallCount == 1)
        #expect(mockCache.saveFeedCallCount == 0)  // Shouldn't try to cache failed network result
    }

    @MainActor
    @Test("FeedRepository - Online, network fails, no cache, throws network error")
    func online_NetworkFails_NoCache_ThrowsNetworkError() async throws {
        // Given
        let (repository, (mockNetwork, mockCache, mockReachability)) = makeSUT(
            networkResult: .failure(NetworkError.invalidResponse),
            isOnline: true,
            cachedFeed: nil
        )
        let url = URL(string: "https://test.com")!

        // When/Then
        do {
            let _ = try await repository.fetchFeed(url: url)
            Issue.record("Expected to throw NetworkError")
        } catch let error as NetworkError {
            #expect(error == .invalidResponse)
            #expect(mockNetwork.executeCallCount == 1)
            #expect(mockReachability.isNetworkAvailableCallCount == 1)
            #expect(mockCache.loadFeedCallCount == 1)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }

    @MainActor
    @Test("FeedRepository - Offline, cache available, returns cache")
    func offline_CacheAvailable_ReturnsCache() async throws {
        // Given
        let (repository, (mockNetwork, mockCache, mockReachability)) = makeSUT(
            networkResult: .success(FeedEntity.mock),  // Shouldn't be called
            isOnline: false,
            cachedFeed: FeedEntity.mock
        )
        let url = URL(string: "https://test.com")!

        // When
        let result = try await repository.fetchFeed(url: url)

        // Then - Should return cached data without network call
        #expect(result.info.count == FeedEntity.mock.info.count)
        #expect(mockNetwork.executeCallCount == 0)  // No network call when offline
        #expect(mockReachability.isNetworkAvailableCallCount == 1)
        #expect(mockCache.loadFeedCallCount == 1)
    }

    @MainActor
    @Test("FeedRepository - Offline, no cache, throws noInternetAndNoCache")
    func offline_NoCache_ThrowsNoInternetAndNoCache() async throws {
        // Given
        let (repository, (mockNetwork, mockCache, mockReachability)) = makeSUT(
            networkResult: .success(FeedEntity.mock),  // Shouldn't be called
            isOnline: false,
            cachedFeed: nil
        )
        let url = URL(string: "https://test.com")!

        // When/Then
        do {
            let _ = try await repository.fetchFeed(url: url)
            Issue.record("Expected to throw FeedRepositoryError.noInternetAndNoCache")
        } catch let error as FeedRepositoryError {
            #expect(error == .noInternetAndNoCache)
            #expect(mockNetwork.executeCallCount == 0)  // No network call when offline
            #expect(mockReachability.isNetworkAvailableCallCount == 1)
            #expect(mockCache.loadFeedCallCount == 1)
        } catch {
            Issue.record("Expected FeedRepositoryError but got \(error)")
        }
    }

    @MainActor
    @Test("FeedRepository - Offline, multiple requests use cache efficiently")
    func offline_MultipleRequests_UseCacheEfficiently() async throws {
        // Given
        let (repository, (mockNetwork, mockCache, mockReachability)) = makeSUT(
            networkResult: .success(FeedEntity.mock),
            isOnline: false,
            cachedFeed: FeedEntity.mock
        )
        let url = URL(string: "https://test.com")!

        // When - Make multiple requests
        let _ = try await repository.fetchFeed(url: url)
        let _ = try await repository.fetchFeed(url: url)
        let _ = try await repository.fetchFeed(url: url)

        // Then - Network should never be called, cache called 3 times
        #expect(mockNetwork.executeCallCount == 0)
        #expect(mockReachability.isNetworkAvailableCallCount == 3)
        #expect(mockCache.loadFeedCallCount == 3)
    }
}

// MARK: - MockNetworkService

final class MockNetworkService: NetworkServiceProtocol {
    
    var result: Result<FeedEntity, Error> = .success(FeedEntity.mock)
    var executeCallCount = 0
    var executeWithCompletionCallCount = 0
    var executeCombineCallCount = 0
    
    func execute<T>(_ request: URLRequest) async throws -> T where T : Decodable {
        executeCallCount += 1
        
        switch result {
        case .success(let entity):
            if let typedResult = entity as? T {
                return typedResult
            } else {
                throw NetworkError.decodingError
            }
        case .failure(let error):
            throw error
        }
    }
    
    func execute<T>(_ request: URLRequest, onCompleted: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        executeWithCompletionCallCount += 1
        
        switch result {
        case .success(let entity):
            if let typedResult = entity as? T {
                onCompleted(.success(typedResult))
            } else {
                onCompleted(.failure(NetworkError.decodingError))
            }
        case .failure(let error):
            onCompleted(.failure(error))
        }
    }
    
    func execute<T>(_ request: URLRequest) -> AnyPublisher<T, Error> where T : Decodable {
        executeCombineCallCount += 1
        
        switch result {
        case .success(let entity):
            if let typedResult = entity as? T {
                return Just(typedResult)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: NetworkError.decodingError)
                    .eraseToAnyPublisher()
            }
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
