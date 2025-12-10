//
//  NewsFeedBuilder.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 21.11.2025.
//

import UIKit

final class NewsFeedBuilder {

    func buildNewsFeed(isUsingMock: Bool = false) -> UINavigationController {

        let repository: NewsFeedRepositoryProtocol

        if isUsingMock {
            repository = MockNewsFeedRepository()
        } else {
            let networkService = NetworkService(session: .shared)
            let modelContext = SwiftDataManager.shared.modelContext
            let cacheRepository = NewsFeedCacheRepository(modelContext: modelContext)
            let networkReachability = NetworkReachability()
            repository = NewsFeedRepository(
                networkService: networkService,
                cacheRepository: cacheRepository,
                networkReachability: networkReachability
            )
        }

        let useCase = NewsFeedUseCase(repository: repository)
        let viewModel = NewsFeedViewModel(useCase: useCase)
        let viewController = NewsFeedViewController(viewModel: viewModel)

        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
