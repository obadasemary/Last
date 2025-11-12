//
//  FeedViewModel.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import Foundation
import Combine

@Observable
final class FeedViewModel {

    private let feedUseCase: FeedUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    private(set) var characters: [CharactersResponse] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    init(feedUseCase: FeedUseCaseProtocol) {
        self.feedUseCase = feedUseCase
    }

    // Completion handler version (currently active)
    func loadDataWithCompletionHandler() {
        isLoading = true
        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.fetchFeedWithCompletion()
        }
        #else
        fetchFeedWithCompletion()
        #endif
    }
    
    // Combine version
    func loadDataWithCombine() {
        isLoading = true
        #if DEBUG
        // Use a non-async delay for Combine path during debug builds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.fetchFeedWithCombine()
        }
        #else
        fetchFeedWithCombine()
        #endif
    }

    // Async/await version
    func loadDataAsync() async {
        isLoading = true

        do {
            #if DEBUG
            try? await Task.sleep(for: .seconds(3))
            #endif
            try await fetchFeedAsync()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    func loadDataAsyncFromCompletion() async {
        isLoading = true
        
        do {
            #if DEBUG
            try? await Task.sleep(for: .seconds(3))
            #endif
            try await fetchFeedFromCompletion()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    func loadDataAsyncFromCombine() async {
        isLoading = true
        
        do {
            #if DEBUG
            try? await Task.sleep(for: .seconds(3))
            #endif
            try await fetchFeedFromCombine()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
}

private extension FeedViewModel {

    func fetchFeedWithCompletion() {
        guard let url = Constants.url else {
            isLoading = false
            return
        }

        feedUseCase.fetchFeed(url: url) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.characters = response.results
                    self.isLoading = false
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func fetchFeedWithCombine() {
        guard let url = Constants.url else {
            isLoading = false
            return
        }

        feedUseCase.fetchFeed(url: url)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self else { return }
                    self.characters = response.results
                }
            )
            .store(in: &cancellables)
    }

    func fetchFeedAsync() async throws {
        guard let url = Constants.url else {
            isLoading = false
            return
        }

        let response = try await feedUseCase.fetchFeed(url: url)
        characters = response.results
    }
    
    func fetchFeedFromCompletion() async throws {
        guard let url = Constants.url else {
            isLoading = false
            return
        }
        
        let response = try await withCheckedThrowingContinuation { continuation in
            feedUseCase.fetchFeed(url: url) { result in
                continuation.resume(with: result)
            }
        }
        characters = response.results
    }
    
    func fetchFeedFromCombine() async throws {
        guard let url = Constants.url else {
            return
        }

        let response: FeedEntity = try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = feedUseCase.fetchFeed(url: url)
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let failure) = completion {
                            continuation.resume(throwing: failure)
                        }
                        cancellable?.cancel()
                    }, receiveValue: { value in
                        continuation.resume(returning: value)
                        cancellable?.cancel()
                    }
                )
        }
        characters = response.results
    }
}
