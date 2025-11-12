//
//  FeedUseCaseTests.swift
//  LastTests
//
//  Created by Abdelrahman Mohamed on 06.11.2025.
//

import Testing
import Foundation
import Combine
@testable import Last

@Suite(.serialized)
struct FeedUseCaseTests {

    // MARK: - Async/Await Tests

    @MainActor
    @Test("FeedUseCase async fetchFeed - Success")
    func asyncFetchFeed_WithSuccess_ReturnsEntity() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .success(FeedEntity.mock)
        let useCase = FeedUseCase(feedRepository: mockRepository)
        let url = URL(string: "https://test.com")!

        // When
        let result = try await useCase.fetchFeed(url: url)

        // Then
        #expect(result.info.count == FeedEntity.mock.info.count)
        #expect(result.info.pages == FeedEntity.mock.info.pages)
        #expect(result.results.count == FeedEntity.mock.results.count)
        #expect(mockRepository.asyncFetchFeedCallCount == 1)
        #expect(mockRepository.lastFetchedURL == url)
    }

    @MainActor
    @Test("FeedUseCase async fetchFeed - Network Error")
    func asyncFetchFeed_WithNetworkError_ThrowsError() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .failure(NetworkError.invalidResponse)
        let useCase = FeedUseCase(feedRepository: mockRepository)
        let url = URL(string: "https://test.com")!

        // When/Then
        do {
            let _ = try await useCase.fetchFeed(url: url)
            Issue.record("Expected to throw error")
        } catch let error as NetworkError {
            #expect(error == .invalidResponse)
            #expect(mockRepository.asyncFetchFeedCallCount == 1)
            #expect(mockRepository.lastFetchedURL == url)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }

    @MainActor
    @Test("FeedUseCase async fetchFeed - Decoding Error")
    func asyncFetchFeed_WithDecodingError_ThrowsError() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .failure(NetworkError.decodingError)
        let useCase = FeedUseCase(feedRepository: mockRepository)
        let url = URL(string: "https://test.com")!

        // When/Then
        do {
            let _ = try await useCase.fetchFeed(url: url)
            Issue.record("Expected to throw error")
        } catch let error as NetworkError {
            #expect(error == .decodingError)
            #expect(mockRepository.asyncFetchFeedCallCount == 1)
            #expect(mockRepository.lastFetchedURL == url)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }

    // MARK: - Completion Handler Tests

    @MainActor
    @Test("FeedUseCase completion fetchFeed - Success")
    func completionFetchFeed_WithSuccess_ReturnsEntity() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .success(FeedEntity.mock)
        let useCase = FeedUseCase(feedRepository: mockRepository)
        let url = URL(string: "https://test.com")!

        // When
        let result: FeedEntity = try await withCheckedThrowingContinuation { continuation in
            useCase.fetchFeed(url: url) { result in
                continuation.resume(with: result)
            }
        }

        // Then
        #expect(result.info.count == FeedEntity.mock.info.count)
        #expect(result.info.pages == FeedEntity.mock.info.pages)
        #expect(result.results.count == FeedEntity.mock.results.count)
        #expect(mockRepository.completionFetchFeedCallCount == 1)
        #expect(mockRepository.lastFetchedURL == url)
    }

    @MainActor
    @Test("FeedUseCase completion fetchFeed - Network Error")
    func completionFetchFeed_WithNetworkError_ReturnsFailure() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .failure(NetworkError.invalidResponse)
        let useCase = FeedUseCase(feedRepository: mockRepository)
        let url = URL(string: "https://test.com")!

        // When/Then
        do {
            let _: FeedEntity = try await withCheckedThrowingContinuation { continuation in
                useCase.fetchFeed(url: url) { result in
                    continuation.resume(with: result)
                }
            }
            Issue.record("Expected to throw error")
        } catch let error as NetworkError {
            #expect(error == .invalidResponse)
            #expect(mockRepository.completionFetchFeedCallCount == 1)
            #expect(mockRepository.lastFetchedURL == url)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }

    @MainActor
    @Test("FeedUseCase completion fetchFeed - Decoding Error")
    func completionFetchFeed_WithDecodingError_ReturnsFailure() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .failure(NetworkError.decodingError)
        let useCase = FeedUseCase(feedRepository: mockRepository)
        let url = URL(string: "https://test.com")!

        // When/Then
        do {
            let _: FeedEntity = try await withCheckedThrowingContinuation { continuation in
                useCase.fetchFeed(url: url) { result in
                    continuation.resume(with: result)
                }
            }
            Issue.record("Expected to throw error")
        } catch let error as NetworkError {
            #expect(error == .decodingError)
            #expect(mockRepository.completionFetchFeedCallCount == 1)
            #expect(mockRepository.lastFetchedURL == url)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }

    // MARK: - Combine Tests

    @MainActor
    @Test("FeedUseCase Combine fetchFeed - Success")
    func combineFetchFeed_WithSuccess_PublishesEntity() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .success(FeedEntity.mock)
        let useCase = FeedUseCase(feedRepository: mockRepository)
        let url = URL(string: "https://test.com")!

        // When
        let publisher: AnyPublisher<FeedEntity, Error> = useCase.fetchFeed(url: url)
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
        #expect(mockRepository.combineFetchFeedCallCount == 1)
        #expect(mockRepository.lastFetchedURL == url)
    }

    @MainActor
    @Test("FeedUseCase Combine fetchFeed - Network Error")
    func combineFetchFeed_WithNetworkError_PublishesError() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .failure(NetworkError.invalidResponse)
        let useCase = FeedUseCase(feedRepository: mockRepository)
        let url = URL(string: "https://test.com")!

        // When/Then
        let publisher: AnyPublisher<FeedEntity, Error> = useCase.fetchFeed(url: url)
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
            #expect(mockRepository.combineFetchFeedCallCount == 1)
            #expect(mockRepository.lastFetchedURL == url)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }

    @MainActor
    @Test("FeedUseCase Combine fetchFeed - Decoding Error")
    func combineFetchFeed_WithDecodingError_PublishesError() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .failure(NetworkError.decodingError)
        let useCase = FeedUseCase(feedRepository: mockRepository)
        let url = URL(string: "https://test.com")!

        // When/Then
        let publisher: AnyPublisher<FeedEntity, Error> = useCase.fetchFeed(url: url)
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
            #expect(mockRepository.combineFetchFeedCallCount == 1)
            #expect(mockRepository.lastFetchedURL == url)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }

    // MARK: - Async Wrapper Tests (Learning)

    @MainActor
    @Test("FeedUseCase fetchFeedFromCompletion - Success")
    func fetchFeedFromCompletion_WithSuccess_ReturnsEntity() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .success(FeedEntity.mock)
        let useCase = FeedUseCase(feedRepository: mockRepository)
        let url = URL(string: "https://test.com")!

        // When
        let result = try await useCase.fetchFeedFromCompletion(url: url)

        // Then
        #expect(result.info.count == FeedEntity.mock.info.count)
        #expect(result.info.pages == FeedEntity.mock.info.pages)
        #expect(result.results.count == FeedEntity.mock.results.count)
        #expect(mockRepository.completionFetchFeedCallCount == 1)
        #expect(mockRepository.lastFetchedURL == url)
    }

    @MainActor
    @Test("FeedUseCase fetchFeedFromCompletion - Network Error")
    func fetchFeedFromCompletion_WithNetworkError_ThrowsError() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .failure(NetworkError.invalidResponse)
        let useCase = FeedUseCase(feedRepository: mockRepository)
        let url = URL(string: "https://test.com")!

        // When/Then
        do {
            let _ = try await useCase.fetchFeedFromCompletion(url: url)
            Issue.record("Expected to throw error")
        } catch let error as NetworkError {
            #expect(error == .invalidResponse)
            #expect(mockRepository.completionFetchFeedCallCount == 1)
            #expect(mockRepository.lastFetchedURL == url)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }

    @MainActor
    @Test("FeedUseCase fetchFeedFromCombine - Success")
    func fetchFeedFromCombine_WithSuccess_ReturnsEntity() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .success(FeedEntity.mock)
        let useCase = FeedUseCase(feedRepository: mockRepository)
        let url = URL(string: "https://test.com")!

        // When
        let result = try await useCase.fetchFeedFromCombine(url: url)

        // Then
        #expect(result.info.count == FeedEntity.mock.info.count)
        #expect(result.info.pages == FeedEntity.mock.info.pages)
        #expect(result.results.count == FeedEntity.mock.results.count)
        #expect(mockRepository.combineFetchFeedCallCount == 1)
        #expect(mockRepository.lastFetchedURL == url)
    }

    @MainActor
    @Test("FeedUseCase fetchFeedFromCombine - Network Error")
    func fetchFeedFromCombine_WithNetworkError_ThrowsError() async throws {
        // Given
        let mockRepository = MockFeedRepositoryForTests()
        mockRepository.result = .failure(NetworkError.invalidResponse)
        let useCase = FeedUseCase(feedRepository: mockRepository)
        let url = URL(string: "https://test.com")!

        // When/Then
        do {
            let _ = try await useCase.fetchFeedFromCombine(url: url)
            Issue.record("Expected to throw error")
        } catch let error as NetworkError {
            #expect(error == .invalidResponse)
            #expect(mockRepository.combineFetchFeedCallCount == 1)
            #expect(mockRepository.lastFetchedURL == url)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }
}

// MARK: - MockFeedRepositoryForTests

final class MockFeedRepositoryForTests: FeedRepositoryProtocol {

    var result: Result<FeedEntity, Error> = .success(FeedEntity.mock)
    var asyncFetchFeedCallCount = 0
    var completionFetchFeedCallCount = 0
    var combineFetchFeedCallCount = 0
    var lastFetchedURL: URL?

    func fetchFeed(url: URL, onComplete: @escaping (Result<FeedEntity, Error>) -> Void) {
        completionFetchFeedCallCount += 1
        lastFetchedURL = url

        switch result {
        case .success(let entity):
            onComplete(.success(entity))
        case .failure(let error):
            onComplete(.failure(error))
        }
    }

    func fetchFeed(url: URL) -> AnyPublisher<FeedEntity, Error> {
        combineFetchFeedCallCount += 1
        lastFetchedURL = url

        switch result {
        case .success(let entity):
            return Just(entity)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }

    func fetchFeed(url: URL) async throws -> FeedEntity {
        asyncFetchFeedCallCount += 1
        lastFetchedURL = url

        switch result {
        case .success(let entity):
            return entity
        case .failure(let error):
            throw error
        }
    }

    func fetchFeedFromCompletion(url: URL) async throws -> FeedEntity {
        // Reuse completion handler implementation
        try await withCheckedThrowingContinuation { continuation in
            fetchFeed(url: url) { result in
                continuation.resume(with: result)
            }
        }
    }

    func fetchFeedFromCombine(url: URL) async throws -> FeedEntity {
        // Reuse Combine implementation
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = fetchFeed(url: url)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                        cancellable?.cancel()
                    }
                )
        }
    }
}

