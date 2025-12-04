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

enum FeedUseCaseError: Error, LocalizedError {
    case noInternetAndNoCache

    var errorDescription: String? {
        switch self {
        case .noInternetAndNoCache:
            return "No internet connection and no cached data available"
        }
    }
}

final class FeedUseCase {

    private let feedRepository: FeedRepositoryProtocol
    private let cacheRepository: CacheRepositoryProtocol
    private let networkReachability: NetworkReachabilityProtocol

    init(
        feedRepository: FeedRepositoryProtocol,
        cacheRepository: CacheRepositoryProtocol,
        networkReachability: NetworkReachabilityProtocol
    ) {
        self.feedRepository = feedRepository
        self.cacheRepository = cacheRepository
        self.networkReachability = networkReachability
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
        let isNetworkAvailable = await networkReachability.isNetworkAvailable()

        if isNetworkAvailable {
            // Try to fetch from network
            do {
                let feed = try await feedRepository.fetchFeed(url: url)
                // Cache the fetched data
                try? await cacheRepository.saveFeed(feed)
                return feed
            } catch {
                // If network fetch fails, try to load from cache
                if let cachedFeed = try? await cacheRepository.loadFeed() {
                    return cachedFeed
                }
                throw error
            }
        } else {
            // No network, load from cache
            if let cachedFeed = try await cacheRepository.loadFeed() {
                return cachedFeed
            }
            throw FeedUseCaseError.noInternetAndNoCache
        }
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
