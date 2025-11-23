//
//  MockNewsFeedRepository.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 21.11.2025.
//

import Foundation
import Combine

final class MockNewsFeedRepository: NewsFeedRepositoryProtocol {
    
    var shouldFail = false
    

    
    func fetchNewsFeed(url: URL) async throws -> NewsFeedEntity {
        if shouldFail {
            throw NetworkError.invalidResponse
        }
        return NewsFeedEntity.mock
    }
}
