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
    private let cacheManager: CacheManagerProtocol
    
    private(set) var cachedImage: UIImage? = nil
    var brightness: CGFloat = 0.75

    init(
        character: CharactersResponse,
        cacheManager: CacheManagerProtocol = CacheManager.instance
    ) {
        self.character = character
        self.cacheManager = cacheManager
    }
    
    func updateBrightness(_ value: CGFloat) {
        brightness = value
    }
    
    func saveToCache(image: UIImage) {
        guard let imageName = character.image?.absoluteString else { return }
        cacheManager.addToCache(image: image, name: imageName)
    }
    
    func removeFromCache() {
        guard let imageName = character.image?.absoluteString else { return }
        cacheManager.removeFromCache(name: imageName)
        // Clear cached image state when removing from cache
        cachedImage = nil
    }
    
    @discardableResult 
    func getFromCache() -> UIImage? {
        guard let imageName = character.image?.absoluteString else { return nil }
        let image = cacheManager.getFromCache(name: imageName)
        cachedImage = image
        return image
    }
}

