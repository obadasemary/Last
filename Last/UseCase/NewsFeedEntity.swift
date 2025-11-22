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
    let air_date: String
    let episode: String
    // let characters: [String] // URLs to characters, omitted for now as not needed for list
    // let url: String
    // let created: String
}

extension NewsFeedEntity {
    static let mock = NewsFeedEntity(
        info: InfoResponse(count: 1, pages: 1),
        results: [
            EpisodeResponse(id: 1, name: "Pilot", air_date: "December 2, 2013", episode: "S01E01"),
            EpisodeResponse(id: 2, name: "Lawnmower Dog", air_date: "December 9, 2013", episode: "S01E02"),
            EpisodeResponse(id: 3, name: "Anatomy Park", air_date: "December 16, 2013", episode: "S01E03")
        ]
    )
}
