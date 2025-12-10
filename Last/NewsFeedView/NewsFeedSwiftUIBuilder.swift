//
//  NewsFeedSwiftUIBuilder.swift
//  Last
//
//  Created by Claude Code on 10.12.2025.
//

import SwiftUI

final class NewsFeedSwiftUIBuilder {

    func buildNewsFeedView(isUsingMock: Bool = false) -> some View {

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

        return NewsFeedView(viewModel: viewModel)
    }
}
