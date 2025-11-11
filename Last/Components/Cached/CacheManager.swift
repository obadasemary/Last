//
//  CacheManager.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 11.11.2025.
//

import UIKit

protocol CacheManagerProtocol {
    func addToCache(image: UIImage, name: String)
    func removeFromCache(name: String)
    func getFromCache(name: String) -> UIImage?
    func clearCache()
    func getCacheSize() -> Int
}

final class CacheManager {

    static let instance = CacheManager() // Singleton

    private var cacheAccessCount: [String: Int] = [:]

    private init() {
        setupMemoryWarningObserver()
    }

    var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()

        cache.countLimit = 100
        cache.totalCostLimit = 100 * 1024 * 1024 // 100mb

        return cache
    }()

    private func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    @objc private func handleMemoryWarning() {
        clearCache()
        let _ = print("🧹 CacheManager: Cache cleared due to memory warning")
    }

    private func calculateImageCost(_ image: UIImage) -> Int {
        guard let cgImage = image.cgImage else { return 0 }
        let bytesPerPixel = 4
        return cgImage.width * cgImage.height * bytesPerPixel
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CacheManager: CacheManagerProtocol {

    func addToCache(image: UIImage, name: String) {
        let cost = calculateImageCost(image)
        imageCache.setObject(image, forKey: name as NSString, cost: cost)
        cacheAccessCount[name] = (cacheAccessCount[name] ?? 0) + 1
        let _ = print("📦 CacheManager: Added '\(name)' to cache (cost: \(cost) bytes)")
    }

    func removeFromCache(name: String) {
        imageCache.removeObject(forKey: name as NSString)
        cacheAccessCount.removeValue(forKey: name)
        let _ = print("🗑️ CacheManager: Removed '\(name)' from cache")
    }

    func getFromCache(name: String) -> UIImage? {
        if let image = imageCache.object(forKey: name as NSString) {
            cacheAccessCount[name] = (cacheAccessCount[name] ?? 0) + 1
            let _ = print("✅ CacheManager: Cache hit for '\(name)' (access count: \(cacheAccessCount[name] ?? 0))")
            return image
        } else {
            let _ = print("❌ CacheManager: Cache miss for '\(name)'")
            return nil
        }
    }

    func clearCache() {
        imageCache.removeAllObjects()
        cacheAccessCount.removeAll()
        let _ = print("🧹 CacheManager: Cache cleared")
    }

    func getCacheSize() -> Int {
        return cacheAccessCount.count
    }
}
