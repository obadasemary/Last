//
//  FeedDetailsViewModel.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//


import Foundation

@Observable
final class FeedDetailsViewModel {

    let character: CharactersResponse

    init(character: CharactersResponse) {
        self.character = character
    }
}
