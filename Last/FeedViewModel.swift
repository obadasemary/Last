//
//  FeedViewModel.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import Foundation

@Observable
final class FeedViewModel {
    
    private let feedUseCase: FeedUseCaseProtocol
    
    private(set) var characters: [CharactersResponse] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    init(feedUseCase: FeedUseCaseProtocol) {
        self.feedUseCase = feedUseCase
    }
    
    func loadData() async {
        isLoading = true
        
        do {
            try? await Task.sleep(for: .seconds(3))
            try await fetchFeed()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

private extension FeedViewModel {
    
    func fetchFeed() async throws {
        guard let url = Constants.url else { return }
        
        let response = try await feedUseCase.fetchFeed(url: url)
        characters = response.results
    }
}
