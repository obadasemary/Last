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

    // MARK: - Async/Await Tests

    @MainActor
    @Test("FeedRepository async fetchFeed - Success")
    func asyncFetchFeed_WithSuccess_ReturnsEntity() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = .success(FeedEntity.mock)
        let repository = FeedRepository(networkService: mockNetworkService)
        let url = URL(string: "https://test.com")!

        // When
        let result = try await repository.fetchFeed(url: url)

        // Then
        #expect(result.info.count == FeedEntity.mock.info.count)
        #expect(result.info.pages == FeedEntity.mock.info.pages)
        #expect(result.results.count == FeedEntity.mock.results.count)
        #expect(mockNetworkService.executeCallCount == 1)
    }

    @MainActor
    @Test("FeedRepository async fetchFeed - Network Error")
    func asyncFetchFeed_WithNetworkError_ThrowsError() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = .failure(NetworkError.invalidResponse)
        let repository = FeedRepository(networkService: mockNetworkService)
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
        let repository = FeedRepository(networkService: mockNetworkService)
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
        let repository = FeedRepository(networkService: mockNetworkService)
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
        #expect(mockNetworkService.executeWithCompletionCallCount == 1)
    }

    @MainActor
    @Test("FeedRepository completion fetchFeed - Network Error")
    func completionFetchFeed_WithNetworkError_ReturnsFailure() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = .failure(NetworkError.invalidResponse)
        let repository = FeedRepository(networkService: mockNetworkService)
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
            #expect(mockNetworkService.executeWithCompletionCallCount == 1)
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
        let repository = FeedRepository(networkService: mockNetworkService)
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
            #expect(mockNetworkService.executeWithCompletionCallCount == 1)
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
        let repository = FeedRepository(networkService: mockNetworkService)
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
        #expect(mockNetworkService.executeCombineCallCount == 1)
    }

    @MainActor
    @Test("FeedRepository Combine fetchFeed - Network Error")
    func combineFetchFeed_WithNetworkError_PublishesError() async throws {
        // Given
        let mockNetworkService = MockNetworkService()
        mockNetworkService.result = .failure(NetworkError.invalidResponse)
        let repository = FeedRepository(networkService: mockNetworkService)
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
            #expect(mockNetworkService.executeCombineCallCount == 1)
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
        let repository = FeedRepository(networkService: mockNetworkService)
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
            #expect(mockNetworkService.executeCombineCallCount == 1)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
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
