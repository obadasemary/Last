//
//  FeedUseCase.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import Foundation
import Combine

protocol FeedUseCaseProtocol {
    func fetchFeed(url: URL, onComplete: @escaping (Result<FeedEntity, Error>) -> Void)
    func fetchFeed(url: URL) -> AnyPublisher<FeedEntity, Error>
    func fetchFeed(url: URL) async throws -> FeedEntity
    
    // Learning: Async/await wrapping different patterns
    func fetchFeedFromCompletion(url: URL) async throws -> FeedEntity
    func fetchFeedFromCombine(url: URL) async throws -> FeedEntity
}

final class FeedUseCase {
    
    private let feedRepository: FeedRepositoryProtocol
    
    init(feedRepository: FeedRepositoryProtocol) {
        self.feedRepository = feedRepository
    }
}

extension FeedUseCase: FeedUseCaseProtocol {
    
    func fetchFeed(
        url: URL,
        onComplete: @escaping (Result<FeedEntity, Error>) -> Void
    ) {
        feedRepository.fetchFeed(url: url) { result in
            switch result {
            case .success(let feed):
                onComplete(.success(feed))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
    
    func fetchFeed(url: URL) -> AnyPublisher<FeedEntity, Error> {
        feedRepository.fetchFeed(url: url)
    }
    
    func fetchFeed(url: URL) async throws -> FeedEntity {
        try await feedRepository.fetchFeed(url: url)
    }
    
    func fetchFeedFromCompletion(url: URL) async throws -> FeedEntity {
        try await withCheckedThrowingContinuation { continuation in
            feedRepository.fetchFeed(url: url) { result in
                continuation.resume(with: result)
            }
        }
    }

    func fetchFeedFromCombine(url: URL) async throws -> FeedEntity {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = feedRepository.fetchFeed(url: url)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                        cancellable?.cancel()
                    }
                )
        }
    }
}
