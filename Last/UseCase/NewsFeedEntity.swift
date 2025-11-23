//
//  NewsFeedEntity.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 21.11.2025.
//

import Foundation

struct NewsFeedEntity: Decodable, Sendable {
    let info: InfoResponse
    let results: [EpisodeResponse]
}

struct EpisodeResponse: Decodable, Identifiable, Equatable, Hashable, Sendable {
    let id: Int
    let name: String
    let airDate: String
    let episode: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, episode
        case airDate = "air_date"
    }
}

extension NewsFeedEntity {
    static let mock = NewsFeedEntity(
        info: InfoResponse(count: 1, pages: 1),
        results: [
            EpisodeResponse(id: 1, name: "Pilot", airDate: "December 2, 2013", episode: "S01E01"),
            EpisodeResponse(id: 2, name: "Lawnmower Dog", airDate: "December 9, 2013", episode: "S01E02"),
            EpisodeResponse(id: 3, name: "Anatomy Park", airDate: "December 16, 2013", episode: "S01E03")
        ]
    )
}
