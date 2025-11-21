//
//  NewsFeedBuilder.swift
//  Last
//
//  Created by Agent on 21.11.2025.
//

import UIKit

final class NewsFeedBuilder {
    
    func buildNewsFeed(isUsingMock: Bool = false) -> UINavigationController {
        
        let repository: NewsFeedRepositoryProtocol
        
        if isUsingMock {
            repository = MockNewsFeedRepository()
        } else {
            let networkService = NetworkService(session: .shared)
            repository = NewsFeedRepository(networkService: networkService)
        }
        
        let useCase = NewsFeedUseCase(repository: repository)
        let viewModel = NewsFeedViewModel(useCase: useCase)
        let viewController = NewsFeedViewController(viewModel: viewModel)
        
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
