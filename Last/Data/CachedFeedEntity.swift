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
    var videoURL: String?
    var videoTitle: String?
    var videoDuration: Double?
    var videoThumbnailURL: String?

    init(
        characterId: Int,
        name: String,
        species: String?,
        imageURL: String?,
        videoId: String? = nil,
        videoURL: String? = nil,
        videoTitle: String? = nil,
        videoDuration: Double? = nil,
        videoThumbnailURL: String? = nil
    ) {
        self.characterId = characterId
        self.name = name
        self.species = species
        self.imageURL = imageURL
        self.videoId = videoId
        self.videoURL = videoURL
        self.videoTitle = videoTitle
        self.videoDuration = videoDuration
        self.videoThumbnailURL = videoThumbnailURL
    }

    convenience init(from character: CharactersResponse) {
        self.init(
            characterId: character.id,
            name: character.name,
            species: character.species,
            imageURL: character.image?.absoluteString,
            videoId: character.video?.id,
            videoURL: character.video?.url.absoluteString,
            videoTitle: character.video?.title,
            videoDuration: character.video?.duration,
            videoThumbnailURL: character.video?.thumbnailURL?.absoluteString
        )
    }

    func toCharactersResponse() -> CharactersResponse {
        // Reconstruct VideoEntity from cached data if available
        let video: VideoEntity? = {
            guard let videoId = videoId,
                  let videoURLString = videoURL,
                  let videoURL = URL(string: videoURLString) else {
                return nil
            }

            return VideoEntity(
                id: videoId,
                url: videoURL,
                thumbnailURL: videoThumbnailURL.flatMap { URL(string: $0) },
                duration: videoDuration,
                title: videoTitle,
                qualities: [.medium(videoURL)] // Store primary quality, others can be derived from HLS if needed
            )
        }()

        return CharactersResponse(
            id: characterId,
            name: name,
            species: species,
            image: imageURL.flatMap { URL(string: $0) },
            video: video
        )
    }
}
