//
//  FeedDetailsBuilder.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import Foundation
import SwiftUI

@Observable
final class FeedDetailsBuilder {

    func buildFeedDetailsView(
        character: CharactersResponse,
        cacheManager: CacheManagerProtocol = CacheManager.instance,
        injectMockVideo: Bool = false
    ) -> some View {
        let viewModel = FeedDetailsViewModel(
            character: character,
            cacheManager: cacheManager,
            injectMockVideo: injectMockVideo
        )
        return FeedDetailsView(viewModel: viewModel)
    }
}
