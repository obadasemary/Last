//
//  ImageDataCacheManager.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 11.11.2025.
//

import Foundation
import UIKit

/// Protocol for caching image data
protocol ImageDataCacheProtocol {
    func addToCache(data: Data, forURL url: URL)
    func getFromCache(forURL url: URL) -> Data?
    func removeFromCache(forURL url: URL)
    func clearCache()
    func getCacheSize() -> Int
}

/// Image data cache manager using Dependency Injection
/// Caches raw image data for better performance and memory efficiency
final class ImageDataCacheManager: ImageDataCacheProtocol {

    // MARK: - Properties

    private let dataCache: NSCache<NSURL, NSData>
    private var cacheAccessCount: [URL: Int] = [:]
    private let countLimit: Int
    private let totalCostLimit: Int

    // MARK: - Initialization

    /// Initialize with custom cache limits
    /// - Parameters:
    ///   - countLimit: Maximum number of cached items (default: 100)
    ///   - totalCostLimit: Maximum memory in bytes (default: 100MB)
    init(countLimit: Int = 100, totalCostLimit: Int = 100 * 1024 * 1024) {
        self.countLimit = countLimit
        self.totalCostLimit = totalCostLimit

        self.dataCache = NSCache<NSURL, NSData>()
        self.dataCache.countLimit = countLimit
        self.dataCache.totalCostLimit = totalCostLimit

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
        let _ = print("🧹 ImageDataCacheManager: Cache cleared due to memory warning")
    }

    // MARK: - ImageDataCacheProtocol Implementation

    func addToCache(data: Data, forURL url: URL) {
        let cost = data.count
        dataCache.setObject(data as NSData, forKey: url as NSURL, cost: cost)
        cacheAccessCount[url] = (cacheAccessCount[url] ?? 0) + 1
        let _ = print("📦 ImageDataCacheManager: Cached '\(url.lastPathComponent)' (\(cost.formatted(.byteCount(style: .memory))))")
    }

    func getFromCache(forURL url: URL) -> Data? {
        if let data = dataCache.object(forKey: url as NSURL) as Data? {
            cacheAccessCount[url] = (cacheAccessCount[url] ?? 0) + 1
            let _ = print("✅ ImageDataCacheManager: Hit '\(url.lastPathComponent)' (access: \(cacheAccessCount[url] ?? 0))")
            return data
        } else {
            let _ = print("❌ ImageDataCacheManager: Miss '\(url.lastPathComponent)'")
            return nil
        }
    }

    func removeFromCache(forURL url: URL) {
        dataCache.removeObject(forKey: url as NSURL)
        cacheAccessCount.removeValue(forKey: url)
        let _ = print("🗑️ ImageDataCacheManager: Removed '\(url.lastPathComponent)'")
    }

    func clearCache() {
        dataCache.removeAllObjects()
        cacheAccessCount.removeAll()
        let _ = print("🧹 ImageDataCacheManager: All cache cleared")
    }

    func getCacheSize() -> Int {
        return cacheAccessCount.count
    }

    // MARK: - Additional Features

    /// Get access count for a specific URL
    func getAccessCount(forURL url: URL) -> Int {
        return cacheAccessCount[url] ?? 0
    }

    /// Check if URL is cached
    func contains(url: URL) -> Bool {
        return dataCache.object(forKey: url as NSURL) != nil
    }

    /// Get most accessed URLs sorted by access count
    func getMostAccessedURLs() -> [(url: URL, count: Int)] {
        return cacheAccessCount
            .sorted { $0.value > $1.value }
            .map { (url: $0.key, count: $0.value) }
    }

    // MARK: - Cleanup

    deinit {
        NotificationCenter.default.removeObserver(self)
        let _ = print("♻️ ImageDataCacheManager: Deinitialized")
    }
}
