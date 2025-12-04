//
//  FeedBuilder.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import Foundation
import SwiftUI

final class FeedBuilder {
    
    func buildFeedView(
        isUsingMock: Bool = false,
        featureFlagManager: FeatureFlagManagerProtocol = FeatureFlagManager.shared
    ) -> some View {

        // Initialize cache repository and network reachability
        let cacheRepository = CacheRepository(modelContext: SwiftDataManager.shared.modelContext)
        let networkReachability = NetworkReachability()

        let feedRepository: FeedRepositoryProtocol

        if isUsingMock {
            feedRepository = MockFeedRepository()
        } else {
            let networkService = NetworkService(session: .shared)
            feedRepository = FeedRepository(
                networkService: networkService,
                cacheRepository: cacheRepository,
                networkReachability: networkReachability
            )
        }

        let feedUseCase = FeedUseCase(feedRepository: feedRepository)

        let viewModel = FeedViewModel(
            feedUseCase: feedUseCase,
            featureFlagManager: featureFlagManager
        )
        let detailsBuilder = FeedDetailsBuilder()

        return FeedView(viewModel: viewModel)
            .environment(detailsBuilder)
    }
}
