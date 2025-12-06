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

        let feedUseCase = FeedUseCaseFactory.createFeedUseCase(isUsingMock: isUsingMock)

        let viewModel = FeedViewModel(
            feedUseCase: feedUseCase,
            featureFlagManager: featureFlagManager
        )
        let detailsBuilder = FeedDetailsBuilder()
        let videoPlayerBuilder = VideoPlayerBuilder()

        return FeedView(viewModel: viewModel)
            .environment(detailsBuilder)
            .environment(videoPlayerBuilder)
    }
}
