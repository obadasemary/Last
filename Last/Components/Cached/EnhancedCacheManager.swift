//
//  EnhancedCacheManager.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 11.11.2025.
//

import UIKit

/// Enhanced cache manager using Dependency Injection pattern
/// Supports testability and flexibility by avoiding singleton
final class EnhancedCacheManager: CacheManagerProtocol {

    // MARK: - Properties

    private let imageCache: NSCache<NSString, UIImage>
    private var cacheAccessCount: [String: Int] = [:]
    private let countLimit: Int
    private let totalCostLimit: Int

    // MARK: - Initialization

    /// Initialize with custom cache limits
    /// - Parameters:
    ///   - countLimit: Maximum number of images (default: 100)
    ///   - totalCostLimit: Maximum memory in bytes (default: 100MB)
    init(countLimit: Int = 100, totalCostLimit: Int = 100 * 1024 * 1024) {
        self.countLimit = countLimit
        self.totalCostLimit = totalCostLimit

        self.imageCache = NSCache<NSString, UIImage>()
        self.imageCache.countLimit = countLimit
        self.imageCache.totalCostLimit = totalCostLimit

        setupMemoryWarningObserver()
    }

    // MARK: - Memory Management

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
        let _ = print("🧹 EnhancedCacheManager: Cache cleared due to memory warning")
    }

    // MARK: - Helper Methods

    private func calculateImageCost(_ image: UIImage) -> Int {
        guard let cgImage = image.cgImage else { return 0 }
        let bytesPerPixel = 4
        return cgImage.width * cgImage.height * bytesPerPixel
    }

    // MARK: - CacheManagerProtocol Implementation

    func addToCache(image: UIImage, name: String) {
        let cost = calculateImageCost(image)
        imageCache.setObject(image, forKey: name as NSString, cost: cost)
        cacheAccessCount[name] = (cacheAccessCount[name] ?? 0) + 1
        let _ = print("📦 EnhancedCacheManager: Added '\(name)' (cost: \(cost.formatted(.byteCount(style: .memory))))")
    }

    func removeFromCache(name: String) {
        imageCache.removeObject(forKey: name as NSString)
        cacheAccessCount.removeValue(forKey: name)
        let _ = print("🗑️ EnhancedCacheManager: Removed '\(name)'")
    }

    func getFromCache(name: String) -> UIImage? {
        if let image = imageCache.object(forKey: name as NSString) {
            cacheAccessCount[name] = (cacheAccessCount[name] ?? 0) + 1
            let _ = print("✅ EnhancedCacheManager: Hit '\(name)' (access: \(cacheAccessCount[name] ?? 0))")
            return image
        } else {
            let _ = print("❌ EnhancedCacheManager: Miss '\(name)'")
            return nil
        }
    }

    func clearCache() {
        imageCache.removeAllObjects()
        cacheAccessCount.removeAll()
        let _ = print("🧹 EnhancedCacheManager: Cache cleared")
    }

    func getCacheSize() -> Int {
        return cacheAccessCount.count
    }

    // MARK: - Additional Features

    /// Get access statistics for a specific image
    func getAccessCount(for name: String) -> Int {
        return cacheAccessCount[name] ?? 0
    }

    /// Get all cached image names sorted by access count
    func getMostAccessedImages() -> [(name: String, count: Int)] {
        return cacheAccessCount
            .sorted { $0.value > $1.value }
            .map { (name: $0.key, count: $0.value) }
    }

    /// Check if an image exists in cache
    func contains(name: String) -> Bool {
        return imageCache.object(forKey: name as NSString) != nil
    }

    // MARK: - Cleanup

    deinit {
        NotificationCenter.default.removeObserver(self)
        let _ = print("♻️ EnhancedCacheManager: Deinitialized")
    }
}
