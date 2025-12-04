//
//  FeedRepository.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import Foundation
import Combine

protocol FeedRepositoryProtocol {
    func fetchFeed(url: URL, onComplete: @escaping (Result<FeedEntity, Error>) -> Void)
    func fetchFeed(url: URL) -> AnyPublisher<FeedEntity, Error>
    func fetchFeed(url: URL) async throws -> FeedEntity

    // Learning: Async/await wrapping different patterns
    func fetchFeedFromCompletion(url: URL) async throws -> FeedEntity
    func fetchFeedFromCombine(url: URL) async throws -> FeedEntity
}

enum FeedRepositoryError: Error, LocalizedError {
    case noInternetAndNoCache

    var errorDescription: String? {
        switch self {
        case .noInternetAndNoCache:
            return "No internet connection and no cached data available"
        }
    }
}

final class FeedRepository {

    private let networkService: NetworkServiceProtocol
    private let cacheRepository: CacheRepositoryProtocol
    private let networkReachability: NetworkReachabilityProtocol

    init(
        networkService: NetworkServiceProtocol,
        cacheRepository: CacheRepositoryProtocol,
        networkReachability: NetworkReachabilityProtocol
    ) {
        self.networkService = networkService
        self.cacheRepository = cacheRepository
        self.networkReachability = networkReachability
    }
}

extension FeedRepository: FeedRepositoryProtocol {
    
    func fetchFeed(
        url: URL,
        onComplete: @escaping (Result<FeedEntity, Error>) -> Void
    ) {
        networkService.execute(URLRequest(url: url)) { (result: Result<FeedEntity, Error>) in
            onComplete(result)
        }
    }
    
    func fetchFeed(url: URL) -> AnyPublisher<FeedEntity, Error> {
        return networkService.execute(URLRequest(url: url))
    }
    
    func fetchFeed(url: URL) async throws -> FeedEntity {
        let isNetworkAvailable = await networkReachability.isNetworkAvailable()

        if isNetworkAvailable {
            // Try to fetch from network
            do {
                let feed: FeedEntity = try await networkService.execute(URLRequest(url: url))
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
            throw FeedRepositoryError.noInternetAndNoCache
        }
    }
    
    func fetchFeedFromCompletion(url: URL) async throws -> FeedEntity {
        try await withCheckedThrowingContinuation { continuation in
            fetchFeed(url: url) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func fetchFeedFromCombine(url: URL) async throws -> FeedEntity {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = fetchFeed(url: url)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    }, receiveValue: { value in
                        continuation.resume(returning: value)
                        cancellable?.cancel()
                    }
                )
        }
    }
}
