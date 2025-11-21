//
//  NewsFeedUseCase.swift
//  Last
//
//  Created by Agent on 21.11.2025.
//

import Foundation
import Combine

protocol NewsFeedUseCaseProtocol {
    func fetchNewsFeed(url: URL) async throws -> NewsFeedEntity
}

final class NewsFeedUseCase {
    
    private let repository: NewsFeedRepositoryProtocol
    
    init(repository: NewsFeedRepositoryProtocol) {
        self.repository = repository
    }
}

extension NewsFeedUseCase: NewsFeedUseCaseProtocol {
    
    func fetchNewsFeed(url: URL) async throws -> NewsFeedEntity {
        try await repository.fetchNewsFeed(url: url)
    }
}
