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

        let feedUseCase = FeedUseCaseFactory.createFeedUseCase(isUsingMock: isUsingMock)
        let viewModel = FeedViewModel(feedUseCase: feedUseCase)
        let feedDetailsBuilder = FeedDetailsBuilder()

        let feedUIKit = FeedUIKit(viewModel: viewModel, feedDetailsBuilder: feedDetailsBuilder)
        let navigationController = UINavigationController(rootViewController: feedUIKit)

        return navigationController
    }
}

