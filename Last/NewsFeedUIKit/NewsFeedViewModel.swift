//
//  NewsFeedViewModel.swift
//  Last
//
//  Created by Agent on 21.11.2025.
//

import Foundation
import Observation

@Observable
final class NewsFeedViewModel {
    
    private(set) var episodes: [EpisodeResponse] = []
    private(set) var isLoading = false
    private(set) var error: Error?
    
    private let useCase: NewsFeedUseCaseProtocol
    
    init(useCase: NewsFeedUseCaseProtocol) {
        self.useCase = useCase
    }
    
    @MainActor
    func loadData() async {
        guard let url = Constants.episodesUrl else { return }
        
        isLoading = true
        error = nil
        
        do {
            let entity = try await useCase.fetchNewsFeed(url: url)
            episodes = entity.results
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}
