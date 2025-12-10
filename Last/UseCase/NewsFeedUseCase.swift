//
//  NewsFeedUseCase.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 21.11.2025.
//

import Foundation

protocol NewsFeedUseCaseProtocol {
    func fetchNewsFeed(url: URL) async throws -> (NewsFeedEntity, isFromRemote: Bool)
}

final class NewsFeedUseCase {

    private let repository: NewsFeedRepositoryProtocol

    init(repository: NewsFeedRepositoryProtocol) {
        self.repository = repository
    }
}

extension NewsFeedUseCase: NewsFeedUseCaseProtocol {

    func fetchNewsFeed(url: URL) async throws -> (NewsFeedEntity, isFromRemote: Bool) {
        try await repository.fetchNewsFeed(url: url)
    }
}
