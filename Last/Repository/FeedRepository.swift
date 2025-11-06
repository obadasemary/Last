//
//  FeedRepository.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import Foundation

protocol FeedRepositoryProtocol {
    func fetchFeed(url: URL, onComplete: @escaping (Result<FeedEntity, Error>) -> Void)
    func fetchFeed(url: URL) async throws -> FeedEntity
}

final class FeedRepository {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
}

extension FeedRepository: FeedRepositoryProtocol {
    func fetchFeed(url: URL) async throws -> FeedEntity {
        try await networkService.execute(URLRequest(url: url))
    }
    
    func fetchFeed(
        url: URL,
        onComplete: @escaping (Result<FeedEntity, Error>) -> Void
    ) {
        networkService.execute(URLRequest(url: url)) { (result: Result<FeedEntity, Error>) in
            onComplete(result)
        }
    }
}
