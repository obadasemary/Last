//
//  CachedNewsFeedEntity.swift
//  Last
//
//  Created by Claude Code on 10.12.2025.
//

import Foundation
import SwiftData

@Model
final class CachedNewsFeedEntity {
    @Attribute(.unique) var id: String
    var count: Int
    var pages: Int
    var episodes: [CachedEpisode]
    var lastUpdated: Date

    init(id: String = "newsfeed", count: Int, pages: Int, episodes: [CachedEpisode], lastUpdated: Date = Date()) {
        self.id = id
        self.count = count
        self.pages = pages
        self.episodes = episodes
        self.lastUpdated = lastUpdated
    }

    convenience init(from newsFeedEntity: NewsFeedEntity) {
        self.init(
            count: newsFeedEntity.info.count,
            pages: newsFeedEntity.info.pages,
            episodes: newsFeedEntity.results.map { CachedEpisode(from: $0) }
        )
    }

    func toNewsFeedEntity() -> NewsFeedEntity {
        NewsFeedEntity(
            info: InfoResponse(count: count, pages: pages),
            results: episodes.map { $0.toEpisodeResponse() }
        )
    }
}

@Model
final class CachedEpisode {
    var episodeId: Int
    var name: String
    var airDate: String
    var episode: String

    init(episodeId: Int, name: String, airDate: String, episode: String) {
        self.episodeId = episodeId
        self.name = name
        self.airDate = airDate
        self.episode = episode
    }

    convenience init(from episode: EpisodeResponse) {
        self.init(
            episodeId: episode.id,
            name: episode.name,
            airDate: episode.airDate,
            episode: episode.episode
        )
    }

    func toEpisodeResponse() -> EpisodeResponse {
        EpisodeResponse(
            id: episodeId,
            name: name,
            airDate: airDate,
            episode: episode
        )
    }
}
