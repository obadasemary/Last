//
//  EnhancedCacheManagerTests.swift
//  LastTests
//
//  Created by Claude Code
//

import Testing
import UIKit
@testable import Last

@Suite
struct EnhancedCacheManagerTests {

    // MARK: - Initialization Tests

    @Test("EnhancedCacheManager initialization - Creates instance with default limits")
    func initialization_CreatesInstanceWithDefaultLimits() {
        // Given & When
        let cacheManager = EnhancedCacheManager()

        // Then
        #expect(cacheManager.getCacheSize() == 0)
    }

    @Test("EnhancedCacheManager initialization - Creates instance with custom limits")
    func initialization_CreatesInstanceWithCustomLimits() {
        // Given
        let customCountLimit = 50
        let customCostLimit = 50 * 1024 * 1024 // 50 MB

        // When
        let cacheManager = EnhancedCacheManager(countLimit: customCountLimit, totalCostLimit: customCostLimit)

        // Then
        #expect(cacheManager.getCacheSize() == 0)
    }

    @Test("EnhancedCacheManager initialization - Multiple instances are independent")
    func initialization_MultipleInstancesAreIndependent() {
        // Given & When
        let manager1 = EnhancedCacheManager()
        let manager2 = EnhancedCacheManager()

        let testImage = createTestImage(width: 100, height: 100)
        manager1.addToCache(image: testImage, name: "test")

        // Then - Instances are independent
        #expect(manager1.getCacheSize() == 1)
        #expect(manager2.getCacheSize() == 0)
    }

    // MARK: - Add to Cache Tests

    @Test("EnhancedCacheManager addToCache - Stores image in cache")
    func addToCache_StoresImageInCache() {
        // Given
        let cacheManager = EnhancedCacheManager()
        let testImage = createTestImage(width: 100, height: 100)
        let imageName = "test_image"

        // When
        cacheManager.addToCache(image: testImage, name: imageName)

        // Then
        let retrievedImage = cacheManager.getFromCache(name: imageName)
        #expect(retrievedImage != nil)
    }

    @Test("EnhancedCacheManager addToCache - Multiple images can be stored")
    func addToCache_MultipleImagesCanBeStored() {
        // Given
        let cacheManager = EnhancedCacheManager()
        let image1 = createTestImage(width: 50, height: 50)
        let image2 = createTestImage(width: 100, height: 100)

        // When
        cacheManager.addToCache(image: image1, name: "image1")
        cacheManager.addToCache(image: image2, name: "image2")

        // Then
        #expect(cacheManager.getFromCache(name: "image1") != nil)
        #expect(cacheManager.getFromCache(name: "image2") != nil)
        #expect(cacheManager.getCacheSize() == 2)
    }

    @Test("EnhancedCacheManager addToCache - Overwrites existing image with same name")
    func addToCache_OverwritesExistingImageWithSameName() {
        // Given
        let cacheManager = EnhancedCacheManager()
        let image1 = createTestImage(width: 50, height: 50)
        let image2 = createTestImage(width: 100, height: 100)
        let imageName = "overwrite_test"

        // When
        cacheManager.addToCache(image: image1, name: imageName)
        cacheManager.addToCache(image: image2, name: imageName)

        // Then
        let retrievedImage = cacheManager.getFromCache(name: imageName)
        #expect(retrievedImage != nil)
        #expect(retrievedImage?.size.width == 100)
        #expect(retrievedImage?.size.height == 100)
        #expect(cacheManager.getCacheSize() == 1) // Still only one entry
    }

    // MARK: - Get from Cache Tests

    @Test("EnhancedCacheManager getFromCache - Returns nil for non-existent image")
    func getFromCache_ReturnsNilForNonExistentImage() {
        // Given
        let cacheManager = EnhancedCacheManager()

        // When
        let retrievedImage = cacheManager.getFromCache(name: "non_existent")

        // Then
        #expect(retrievedImage == nil)
    }

    @Test("EnhancedCacheManager getFromCache - Returns cached image")
    func getFromCache_ReturnsCachedImage() {
        // Given
        let cacheManager = EnhancedCacheManager()
        let testImage = createTestImage(width: 100, height: 100)
        let imageName = "cached_image"

        // When
        cacheManager.addToCache(image: testImage, name: imageName)
        let retrievedImage = cacheManager.getFromCache(name: imageName)

        // Then
        #expect(retrievedImage != nil)
        #expect(retrievedImage?.size == testImage.size)
    }

    // MARK: - Remove from Cache Tests

    @Test("EnhancedCacheManager removeFromCache - Removes image from cache")
    func removeFromCache_RemovesImageFromCache() {
        // Given
        let cacheManager = EnhancedCacheManager()
        let testImage = createTestImage(width: 100, height: 100)
        let imageName = "remove_test"

        cacheManager.addToCache(image: testImage, name: imageName)
        #expect(cacheManager.getFromCache(name: imageName) != nil)

        // When
        cacheManager.removeFromCache(name: imageName)

        // Then
        let retrievedImage = cacheManager.getFromCache(name: imageName)
        #expect(retrievedImage == nil)
    }

    @Test("EnhancedCacheManager removeFromCache - Safe to call on non-existent image")
    func removeFromCache_SafeToCallOnNonExistentImage() {
        // Given
        let cacheManager = EnhancedCacheManager()

        // When & Then - Should not crash
        cacheManager.removeFromCache(name: "non_existent")
    }

    // MARK: - Clear Cache Tests

    @Test("EnhancedCacheManager clearCache - Removes all images from cache")
    func clearCache_RemovesAllImagesFromCache() {
        // Given
        let cacheManager = EnhancedCacheManager()
        let image1 = createTestImage(width: 50, height: 50)
        let image2 = createTestImage(width: 100, height: 100)

        cacheManager.addToCache(image: image1, name: "image1")
        cacheManager.addToCache(image: image2, name: "image2")

        // When
        cacheManager.clearCache()

        // Then
        #expect(cacheManager.getFromCache(name: "image1") == nil)
        #expect(cacheManager.getFromCache(name: "image2") == nil)
        #expect(cacheManager.getCacheSize() == 0)
    }

    // MARK: - Cache Size Tests

    @Test("EnhancedCacheManager getCacheSize - Returns correct cache size")
    func getCacheSize_ReturnsCorrectCacheSize() {
        // Given
        let cacheManager = EnhancedCacheManager()
        let image1 = createTestImage(width: 50, height: 50)
        let image2 = createTestImage(width: 100, height: 100)

        // When
        let initialSize = cacheManager.getCacheSize()
        #expect(initialSize == 0)

        cacheManager.addToCache(image: image1, name: "image1")
        let sizeAfterOne = cacheManager.getCacheSize()
        #expect(sizeAfterOne == 1)

        cacheManager.addToCache(image: image2, name: "image2")
        let sizeAfterTwo = cacheManager.getCacheSize()
        #expect(sizeAfterTwo == 2)

        cacheManager.removeFromCache(name: "image1")
        let sizeAfterRemove = cacheManager.getCacheSize()
        #expect(sizeAfterRemove == 1)
    }

    // MARK: - Additional Features Tests

    @Test("EnhancedCacheManager getAccessCount - Returns correct access count")
    func getAccessCount_ReturnsCorrectAccessCount() {
        // Given
        let cacheManager = EnhancedCacheManager()
        let testImage = createTestImage(width: 100, height: 100)
        let imageName = "access_test"

        // When
        let initialCount = cacheManager.getAccessCount(for: imageName)
        #expect(initialCount == 0)

        cacheManager.addToCache(image: testImage, name: imageName)
        let countAfterAdd = cacheManager.getAccessCount(for: imageName)
        #expect(countAfterAdd == 1)

        let _ = cacheManager.getFromCache(name: imageName)
        let countAfterGet = cacheManager.getAccessCount(for: imageName)
        #expect(countAfterGet == 2)

        let _ = cacheManager.getFromCache(name: imageName)
        let _ = cacheManager.getFromCache(name: imageName)
        let countAfterMultipleGets = cacheManager.getAccessCount(for: imageName)
        #expect(countAfterMultipleGets == 4)
    }

    @Test("EnhancedCacheManager contains - Returns correct containment status")
    func contains_ReturnsCorrectContainmentStatus() {
        // Given
        let cacheManager = EnhancedCacheManager()
        let testImage = createTestImage(width: 100, height: 100)
        let imageName = "contains_test"

        // When
        let initialContains = cacheManager.contains(name: imageName)
        #expect(initialContains == false)

        cacheManager.addToCache(image: testImage, name: imageName)
        let containsAfterAdd = cacheManager.contains(name: imageName)
        #expect(containsAfterAdd == true)

        cacheManager.removeFromCache(name: imageName)
        let containsAfterRemove = cacheManager.contains(name: imageName)
        #expect(containsAfterRemove == false)
    }

    @Test("EnhancedCacheManager getMostAccessedImages - Returns sorted by access count")
    func getMostAccessedImages_ReturnsSortedByAccessCount() {
        // Given
        let cacheManager = EnhancedCacheManager()
        let image1 = createTestImage(width: 50, height: 50)
        let image2 = createTestImage(width: 100, height: 100)
        let image3 = createTestImage(width: 75, height: 75)

        // When
        cacheManager.addToCache(image: image1, name: "image1")
        cacheManager.addToCache(image: image2, name: "image2")
        cacheManager.addToCache(image: image3, name: "image3")

        // Access with different frequencies
        let _ = cacheManager.getFromCache(name: "image1")
        let _ = cacheManager.getFromCache(name: "image1")
        let _ = cacheManager.getFromCache(name: "image1") // image1: 4 accesses (1 add + 3 gets)

        let _ = cacheManager.getFromCache(name: "image2") // image2: 2 accesses (1 add + 1 get)

        let _ = cacheManager.getFromCache(name: "image3")
        let _ = cacheManager.getFromCache(name: "image3")
        let _ = cacheManager.getFromCache(name: "image3")
        let _ = cacheManager.getFromCache(name: "image3") // image3: 5 accesses (1 add + 4 gets)

        let mostAccessed = cacheManager.getMostAccessedImages()

        // Then
        #expect(mostAccessed.count == 3)
        #expect(mostAccessed[0].name == "image3")
        #expect(mostAccessed[0].count == 5)
        #expect(mostAccessed[1].name == "image1")
        #expect(mostAccessed[1].count == 4)
        #expect(mostAccessed[2].name == "image2")
        #expect(mostAccessed[2].count == 2)
    }

    // MARK: - Integration Tests

    @Test("EnhancedCacheManager - Complete cache workflow")
    func completeCacheWorkflow_WorksCorrectly() {
        // Given
        let cacheManager = EnhancedCacheManager()
        let testImage = createTestImage(width: 100, height: 100)
        let imageName = "workflow_test"

        // Verify cache is empty
        #expect(cacheManager.getFromCache(name: imageName) == nil)
        #expect(cacheManager.getCacheSize() == 0)
        #expect(cacheManager.contains(name: imageName) == false)

        // Add image
        cacheManager.addToCache(image: testImage, name: imageName)
        #expect(cacheManager.getCacheSize() == 1)
        #expect(cacheManager.contains(name: imageName) == true)
        #expect(cacheManager.getAccessCount(for: imageName) == 1)

        // Retrieve image
        let retrievedImage = cacheManager.getFromCache(name: imageName)
        #expect(retrievedImage != nil)
        #expect(retrievedImage?.size == testImage.size)
        #expect(cacheManager.getAccessCount(for: imageName) == 2)

        // Remove image
        cacheManager.removeFromCache(name: imageName)
        #expect(cacheManager.getFromCache(name: imageName) == nil)
        #expect(cacheManager.getCacheSize() == 0)
        #expect(cacheManager.contains(name: imageName) == false)
        #expect(cacheManager.getAccessCount(for: imageName) == 0)
    }

    @Test("EnhancedCacheManager - Protocol conformance")
    func protocolConformance_WorksCorrectly() {
        // Given
        let cacheManager: CacheManagerProtocol = EnhancedCacheManager()
        let testImage = createTestImage(width: 100, height: 100)
        let imageName = "protocol_test"

        // When - Use through protocol
        cacheManager.addToCache(image: testImage, name: imageName)
        let retrievedImage = cacheManager.getFromCache(name: imageName)
        let cacheSize = cacheManager.getCacheSize()

        // Then
        #expect(retrievedImage != nil)
        #expect(cacheSize == 1)

        cacheManager.removeFromCache(name: imageName)
        #expect(cacheManager.getFromCache(name: imageName) == nil)

        cacheManager.clearCache()
        #expect(cacheManager.getCacheSize() == 0)
    }

    @Test("EnhancedCacheManager - Dependency injection in tests")
    func dependencyInjection_WorksInTests() {
        // Given - Can create multiple independent instances for testing
        let testCache1 = EnhancedCacheManager(countLimit: 10, totalCostLimit: 10 * 1024 * 1024)
        let testCache2 = EnhancedCacheManager(countLimit: 20, totalCostLimit: 20 * 1024 * 1024)

        let testImage = createTestImage(width: 100, height: 100)

        // When
        testCache1.addToCache(image: testImage, name: "test")
        testCache2.addToCache(image: testImage, name: "test")

        // Then - Both caches work independently
        #expect(testCache1.getCacheSize() == 1)
        #expect(testCache2.getCacheSize() == 1)

        testCache1.clearCache()
        #expect(testCache1.getCacheSize() == 0)
        #expect(testCache2.getCacheSize() == 1) // testCache2 unaffected
    }

    // MARK: - Helper Methods

    private func createTestImage(width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.green.cgColor)
        context.fill(CGRect(origin: .zero, size: size))

        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}
