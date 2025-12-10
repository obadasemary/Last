//
//  NewsFeedViewModelTests.swift
//  LastTests
//
//  Created by Abdelrahman Mohamed on 21.11.2025.
//

import Testing
import Foundation
@testable import Last

@Suite(.serialized)
struct NewsFeedViewModelTests {
    
    @MainActor
    @Test("NewsFeedViewModel loadData - Success")
    func loadData_WithSuccess_UpdatesEpisodes() async throws {
        // Given
        let mockUseCase = MockNewsFeedUseCase() // Using the one from main target
        mockUseCase.shouldFail = false
        mockUseCase.isFromRemote = true
        let viewModel = NewsFeedViewModel(useCase: mockUseCase)

        // When
        await viewModel.loadData()

        // Then
        #expect(viewModel.episodes.count == NewsFeedEntity.mock.results.count)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
        #expect(viewModel.isFromRemote == true)
    }
    
    @MainActor
    @Test("NewsFeedViewModel loadData - Failure")
    func loadData_WithFailure_SetsError() async throws {
        // Given
        let mockUseCase = MockNewsFeedUseCase()
        mockUseCase.shouldFail = true
        let viewModel = NewsFeedViewModel(useCase: mockUseCase)
        
        // When
        await viewModel.loadData()
        
        // Then
        #expect(viewModel.episodes.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error != nil)
    }
}
