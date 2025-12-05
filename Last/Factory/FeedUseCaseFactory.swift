//
//  FeedUseCaseFactory.swift
//  Last
//
//  Created by Claude Code on 05.12.2025.
//

import Foundation

/// Factory for creating FeedUseCase instances with their dependencies
/// Centralizes the creation of FeedUseCase to avoid duplication across builders
final class FeedUseCaseFactory {

    /// Creates a configured FeedUseCase with all its dependencies
    /// - Parameter isUsingMock: If true, returns a mock implementation for testing/previews
    /// - Returns: A fully configured FeedUseCase instance
    static func createFeedUseCase(isUsingMock: Bool = false) -> FeedUseCaseProtocol {
        let feedRepository: FeedRepositoryProtocol

        if isUsingMock {
            feedRepository = MockFeedRepository()
        } else {
            // Initialize cache repository and network reachability
            let cacheRepository = CacheRepository(modelContext: SwiftDataManager.shared.modelContext)
            let networkReachability = NetworkReachability()
            let networkService = NetworkService(session: .shared)

            feedRepository = FeedRepository(
                networkService: networkService,
                cacheRepository: cacheRepository,
                networkReachability: networkReachability
            )
        }

        return FeedUseCase(feedRepository: feedRepository)
    }
}
