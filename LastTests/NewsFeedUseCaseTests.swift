//
//  NewsFeedUseCaseTests.swift
//  LastTests
//
//  Created by Abdelrahman Mohamed on 21.11.2025.
//

import Testing
import Foundation
import Combine
@testable import Last

@Suite(.serialized)
struct NewsFeedUseCaseTests {
    
    @MainActor
    @Test("NewsFeedUseCase fetchNewsFeed - Success")
    func fetchNewsFeed_WithSuccess_ReturnsEntity() async throws {
        // Given
        let mockRepository = MockNewsFeedRepositoryForTests()
        mockRepository.result = .success(NewsFeedEntity.mock)
        let useCase = NewsFeedUseCase(repository: mockRepository)
        let url = URL(string: "https://test.com")!
        
        // When
        let result = try await useCase.fetchNewsFeed(url: url)
        
        // Then
        #expect(result.results.count == NewsFeedEntity.mock.results.count)
        #expect(mockRepository.fetchNewsFeedCallCount == 1)
        #expect(mockRepository.lastFetchedURL == url)
    }
    
    @MainActor
    @Test("NewsFeedUseCase fetchNewsFeed - Network Error")
    func fetchNewsFeed_WithNetworkError_ThrowsError() async throws {
        // Given
        let mockRepository = MockNewsFeedRepositoryForTests()
        mockRepository.result = .failure(NetworkError.invalidResponse)
        let useCase = NewsFeedUseCase(repository: mockRepository)
        let url = URL(string: "https://test.com")!
        
        // When/Then
        do {
            let _ = try await useCase.fetchNewsFeed(url: url)
            Issue.record("Expected to throw error")
        } catch let error as NetworkError {
            #expect(error == .invalidResponse)
            #expect(mockRepository.fetchNewsFeedCallCount == 1)
            #expect(mockRepository.lastFetchedURL == url)
        } catch {
            Issue.record("Expected NetworkError but got \(error)")
        }
    }
}

// MARK: - MockNewsFeedRepositoryForTests

final class MockNewsFeedRepositoryForTests: NewsFeedRepositoryProtocol {
    
    var result: Result<NewsFeedEntity, Error> = .success(NewsFeedEntity.mock)
    var fetchNewsFeedCallCount = 0
    var lastFetchedURL: URL?
    

    
    func fetchNewsFeed(url: URL) async throws -> NewsFeedEntity {
        fetchNewsFeedCallCount += 1
        lastFetchedURL = url
        
        switch result {
        case .success(let entity):
            return entity
        case .failure(let error):
            throw error
        }
    }
}
