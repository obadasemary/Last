//
//  FeedBuilder.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import Foundation
import SwiftUI

final class FeedBuilder {
    
    func buildFeedView(isUsingMock: Bool = false) -> some View {
        
        let feedRepository: FeedRepositoryProtocol
        
        if isUsingMock {
            feedRepository = MockFeedRepository()
        } else {
            let networkService = NetworkService(session: .shared)
            feedRepository = FeedRepository(networkService: networkService)
        }
        
        let feedUseCase = FeedUseCase(feedRepository: feedRepository)
        
        let viewModel = FeedViewModel(feedUseCase: feedUseCase)
        let detailsBuilder = FeedDetailsBuilder()
        return FeedView(viewModel: viewModel)
            .environment(detailsBuilder)
    }
}
