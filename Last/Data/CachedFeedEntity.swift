//
//  CachedFeedEntity.swift
//  Last
//
//  Created by Claude Code on 04.12.2025.
//

import Foundation
import SwiftData

@Model
final class CachedFeedEntity {
    @Attribute(.unique) var id: String
    var count: Int
    var pages: Int
    var characters: [CachedCharacter]
    var lastUpdated: Date

    init(id: String = "feed", count: Int, pages: Int, characters: [CachedCharacter], lastUpdated: Date = Date()) {
        self.id = id
        self.count = count
        self.pages = pages
        self.characters = characters
        self.lastUpdated = lastUpdated
    }

    convenience init(from feedEntity: FeedEntity) {
        self.init(
            count: feedEntity.info.count,
            pages: feedEntity.info.pages,
            characters: feedEntity.results.map { CachedCharacter(from: $0) }
        )
    }

    func toFeedEntity() -> FeedEntity {
        FeedEntity(
            info: InfoResponse(count: count, pages: pages),
            results: characters.map { $0.toCharactersResponse() }
        )
    }
}

@Model
final class CachedCharacter {
    var characterId: Int
    var name: String
    var species: String?
    var imageURL: String?
    var videoId: String?

    init(characterId: Int, name: String, species: String?, imageURL: String?, videoId: String? = nil) {
        self.characterId = characterId
        self.name = name
        self.species = species
        self.imageURL = imageURL
        self.videoId = videoId
    }

    convenience init(from character: CharactersResponse) {
        self.init(
            characterId: character.id,
            name: character.name,
            species: character.species,
            imageURL: character.image?.absoluteString,
            videoId: character.video?.id
        )
    }

    func toCharactersResponse() -> CharactersResponse {
        CharactersResponse(
            id: characterId,
            name: name,
            species: species,
            image: imageURL.flatMap { URL(string: $0) },
            video: nil  // Video is not cached in SwiftData, only referenced by ID
        )
    }
}
