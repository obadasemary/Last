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
        cacheManager: CacheManagerProtocol = CacheManager.instance
    ) -> some View {
        let viewModel = FeedDetailsViewModel(
            character: character,
            cacheManager: cacheManager
        )
        return FeedDetailsView(viewModel: viewModel)
    }
}
