//
//  Constants.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import Foundation

enum Constants {
    static let url = URL(string: "https://rickandmortyapi.com/api/character")
    static let randomImage = "https://picsum.photos/600/600"
    static let imageDimensions: CGFloat = 100
    static let cornerRadius: CGFloat = 4
    
    static func randomImageURL() -> URL {
        guard let url = URL(string: randomImage) else {
            return URL(string: "https://picsum.photos/600/600")!
        }
        
        return url
    }
}
