//
//  FeedEntity.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 02.11.2025.
//

import Foundation

struct FeedEntity: Decodable, Sendable {

    let info: InfoResponse
    let results: [CharactersResponse]
}

extension FeedEntity {
    
    static let mock = FeedEntity(
        info: InfoResponse(
            count: 1,
            pages: 1
        ),
        results: [
            CharactersResponse(
                id: 1,
                name: "Obada",
                species: "Engineer",
                image: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
            ),
            CharactersResponse(
                id: 2,
                name: "Sara",
                species: "Engineer",
                image: URL(string: "https://rickandmortyapi.com/api/character/avatar/2.jpeg")
            ),
            CharactersResponse(
                id: 3,
                name: "Omar",
                species: "Engineer",
                image: URL(string: "https://rickandmortyapi.com/api/character/avatar/3.jpeg")
            ),
            CharactersResponse(
                id: 4,
                name: "Nazli",
                species: "Engineer",
                image: URL(string: "https://rickandmortyapi.com/api/character/avatar/4.jpeg")
            )
        ]
    )
}

struct InfoResponse: Decodable, Sendable {
    let count: Int
    let pages: Int
}

struct CharactersResponse: Decodable, Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
    let species: String?
    let image: URL?
}
