//
//  NewsFeedRepository.swift
//  Last
//
//  Created by Agent on 21.11.2025.
//

import Foundation
import Combine

protocol NewsFeedRepositoryProtocol {
    func fetchNewsFeed(url: URL, onComplete: @escaping (Result<NewsFeedEntity, Error>) -> Void)
    func fetchNewsFeed(url: URL) -> AnyPublisher<NewsFeedEntity, Error>
    func fetchNewsFeed(url: URL) async throws -> NewsFeedEntity
}

final class NewsFeedRepository {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
}

extension NewsFeedRepository: NewsFeedRepositoryProtocol {
    
    func fetchNewsFeed(
        url: URL,
        onComplete: @escaping (Result<NewsFeedEntity, Error>) -> Void
    ) {
        let request = URLRequest(url: url)
        networkService.execute(request, onCompleted: onComplete)
    }
    
    func fetchNewsFeed(url: URL) -> AnyPublisher<NewsFeedEntity, Error> {
        let request = URLRequest(url: url)
        return networkService.execute(request)
    }
    
    func fetchNewsFeed(url: URL) async throws -> NewsFeedEntity {
        let request = URLRequest(url: url)
        return try await networkService.execute(request)
    }
}
