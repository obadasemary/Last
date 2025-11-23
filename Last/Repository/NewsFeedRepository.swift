//
//  NewsFeedRepository.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 21.11.2025.
//

import Foundation
import Combine

protocol NewsFeedRepositoryProtocol {
    func fetchNewsFeed(url: URL) async throws -> NewsFeedEntity
}

final class NewsFeedRepository {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
}

extension NewsFeedRepository: NewsFeedRepositoryProtocol {
    
    func fetchNewsFeed(url: URL) async throws -> NewsFeedEntity {
        let request = URLRequest(url: url)
        return try await networkService.execute(request)
    }
}
