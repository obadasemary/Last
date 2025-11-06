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

    func buildFeedDetailsView(character: CharactersResponse) -> some View {
        let viewModel = FeedDetailsViewModel(character: character)
        return FeedDetailsView(viewModel: viewModel)
    }
}
