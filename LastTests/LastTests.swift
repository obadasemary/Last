//
//  LastTests.swift
//  LastTests
//
//  Created by Abdelrahman Mohamed on 02.11.2025.
//

import Testing
@testable import Last

struct LastTests {

    @MainActor
    @Test("Test Fetch Feed with Success")
    func fetchFeed_OnSuccess() async throws {
        let response = FeedEntity.mock
        let makeSut = {
            MockFeedUseCase(
                result:
                        .success(
                            response
                        )
            )
        }
        
        let viewModel = FeedViewModel(feedUseCase: makeSut())
        
        await viewModel.loadData()
        
        #expect(viewModel.characters == response.results)
    }

    @MainActor
    @Test("Test Fetch Feed with Failure")
    func fetchFeed_OnFailure() async throws {
        let makeSut = {
            MockFeedUseCase(result: .failure(MockError.stub))
        }
        
        let viewModel = FeedViewModel(feedUseCase: makeSut())
        
        await viewModel.loadData()
        
        #expect(viewModel.characters.isEmpty)
    }
}

extension LastTests {
    enum MockError: Error {
        case  stub
    }
}
