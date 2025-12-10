//
//  NewsFeedRepository.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 21.11.2025.
//

import Foundation
import os.log

protocol NewsFeedRepositoryProtocol {
    func fetchNewsFeed(url: URL) async throws -> (NewsFeedEntity, isFromRemote: Bool)
}

enum NewsFeedRepositoryError: Error, LocalizedError {
    case noInternetAndNoCache

    var errorDescription: String? {
        switch self {
        case .noInternetAndNoCache:
            return "No internet connection and no cached data available"
        }
    }
}

final class NewsFeedRepository {

    private let networkService: NetworkServiceProtocol
    private let cacheRepository: NewsFeedCacheRepositoryProtocol
    private let networkReachability: NetworkReachabilityProtocol
    private let logger = Logger(subsystem: "com.SamuraiStudios.Last", category: "NewsFeedRepository")

    init(
        networkService: NetworkServiceProtocol,
        cacheRepository: NewsFeedCacheRepositoryProtocol,
        networkReachability: NetworkReachabilityProtocol
    ) {
        self.networkService = networkService
        self.cacheRepository = cacheRepository
        self.networkReachability = networkReachability
    }
}

extension NewsFeedRepository: NewsFeedRepositoryProtocol {

    /// Fetches news feed data with offline fallback strategy
    ///
    /// Strategy:
    /// 1. If online: Fetch from network → Cache result → Return data with isFromRemote = true
    ///    - On network failure: Try cache as fallback with isFromRemote = false
    /// 2. If offline: Return cached data with isFromRemote = false
    ///    - If no cache: Throw noInternetAndNoCache error
    ///
    /// This ensures users always get data when possible, with graceful degradation
    func fetchNewsFeed(url: URL) async throws -> (NewsFeedEntity, isFromRemote: Bool) {
        let isNetworkAvailable = await networkReachability.isNetworkAvailable()

        if isNetworkAvailable {
            // Try to fetch from network
            do {
                let request = URLRequest(url: url)
                let feed: NewsFeedEntity = try await networkService.execute(request)
                // Cache the fetched data (fire and forget - don't fail request if caching fails)
                try? await cacheRepository.saveNewsFeed(feed)
                logger.info("News feed fetched from remote and cached")
                return (feed, isFromRemote: true)
            } catch let networkError {
                // If network fetch fails, try to load from cache
                if let cachedFeed = try? await cacheRepository.loadNewsFeed() {
                    logger.info("Network request failed, returning cached news feed")
                    return (cachedFeed, isFromRemote: false)
                }
                // No cache available, throw the original network error
                logger.error("Network request failed and no cache available: \(networkError.localizedDescription)")
                throw networkError
            }
        } else {
            // No network, load from cache
            if let cachedFeed = try await cacheRepository.loadNewsFeed() {
                logger.info("No network available, returning cached news feed")
                return (cachedFeed, isFromRemote: false)
            }
            throw NewsFeedRepositoryError.noInternetAndNoCache
        }
    }
}
