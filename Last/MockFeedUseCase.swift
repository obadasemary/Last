//
//  MockFeedUseCase.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//


import Foundation

class MockFeedUseCase: FeedUseCaseProtocol {
    
    private let result: Result<FeedEntity, Error>
    
    init(result: Result<FeedEntity, Error>) {
        self.result = result
    }
    
    func fetchFeed(url: URL) async throws -> FeedEntity {
        switch result {
        case .success(let response):
            response
        case .failure(let error):
            throw error
        }
    }
}