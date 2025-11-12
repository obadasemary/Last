//
//  MockCacheManager.swift
//  LastTests
//
//  Created by Claude Code
//

import UIKit
@testable import Last

final class MockCacheManager: CacheManagerProtocol {
    
    private var cache: [String: UIImage] = [:]
    var addToCacheCallCount = 0
    var removeFromCacheCallCount = 0
    var getFromCacheCallCount = 0
    var clearCacheCallCount = 0
    
    func addToCache(image: UIImage, name: String) {
        addToCacheCallCount += 1
        cache[name] = image
    }
    
    func removeFromCache(name: String) {
        removeFromCacheCallCount += 1
        cache.removeValue(forKey: name)
    }
    
    func getFromCache(name: String) -> UIImage? {
        getFromCacheCallCount += 1
        return cache[name]
    }
    
    func clearCache() {
        clearCacheCallCount += 1
        cache.removeAll()
    }
    
    func getCacheSize() -> Int {
        return cache.count
    }
    
    // Helper method for testing
    func reset() {
        cache.removeAll()
        addToCacheCallCount = 0
        removeFromCacheCallCount = 0
        getFromCacheCallCount = 0
        clearCacheCallCount = 0
    }
}

