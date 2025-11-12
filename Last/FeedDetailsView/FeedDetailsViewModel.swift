//
//  FeedDetailsViewModel.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//


import Foundation
import UIKit

@Observable
final class FeedDetailsViewModel {

    let character: CharactersResponse
    let cacheManager = CacheManager.instance
    
    private(set) var cachedImage: UIImage? = nil
    var brightness: CGFloat = 0.75

    init(
        character: CharactersResponse
    ) {
        self.character = character
    }
    
    func saveToCache(image: UIImage) {
        guard let imageName = character.image?.absoluteString else { return }
        cacheManager.addToCache(image: image, name: imageName)
    }
    
    func removeFromCache() {
        guard let imageName = character.image?.absoluteString else { return }
        cacheManager.removeFromCache(name: imageName)
    }
    
    @discardableResult 
    func getFromCache() -> UIImage? {
        guard let imageName = character.image?.absoluteString else { return nil }
        let image = cacheManager.getFromCache(name: imageName)
        cachedImage = image
        return image
    }
}

