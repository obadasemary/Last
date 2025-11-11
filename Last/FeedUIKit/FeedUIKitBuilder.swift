//
//  FeedUIKitBuilder.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import Foundation
import UIKit

final class FeedUIKitBuilder {
    
    func buildFeedUIKit(isUsingMock: Bool = false) -> UINavigationController {
        
        let feedRepository: FeedRepositoryProtocol
        
        if isUsingMock {
            feedRepository = MockFeedRepository()
        } else {
            let networkService = NetworkService(session: .shared)
            feedRepository = FeedRepository(networkService: networkService)
        }
        
        let feedUseCase = FeedUseCase(feedRepository: feedRepository)
        let viewModel = FeedViewModel(feedUseCase: feedUseCase)
        let feedDetailsBuilder = FeedDetailsBuilder()
        
        let feedUIKit = FeedUIKit(viewModel: viewModel, feedDetailsBuilder: feedDetailsBuilder)
        let navigationController = UINavigationController(rootViewController: feedUIKit)
        
        return navigationController
    }
}

