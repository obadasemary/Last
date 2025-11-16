//
//  ImageDataCacheManagerTests.swift
//  LastTests
//
//  Created by Claude Code
//

import Testing
import Foundation
import UIKit
@testable import Last

@Suite
struct ImageDataCacheManagerTests {

    // MARK: - Initialization Tests

    @Test("ImageDataCacheManager initialization - Creates instance with default limits")
    func initialization_CreatesInstanceWithDefaultLimits() {
        // Given & When
        let cacheManager = ImageDataCacheManager()

        // Then
        #expect(cacheManager.getCacheSize() == 0)
    }

    @Test("ImageDataCacheManager initialization - Creates instance with custom limits")
    func initialization_CreatesInstanceWithCustomLimits() {
        // Given
        let customCountLimit = 50
        let customCostLimit = 50 * 1024 * 1024 // 50 MB

        // When
        let cacheManager = ImageDataCacheManager(countLimit: customCountLimit, totalCostLimit: customCostLimit)

        // Then
        #expect(cacheManager.getCacheSize() == 0)
    }

    @Test("ImageDataCacheManager initialization - Multiple instances are independent")
    func initialization_MultipleInstancesAreIndependent() {
        // Given & When
        let manager1 = ImageDataCacheManager()
        let manager2 = ImageDataCacheManager()

        let testData = createTestImageData(width: 100, height: 100)
        let testURL = URL(string: "https://test.com/image1.jpg")!
        manager1.addToCache(data: testData, forURL: testURL)

        // Then - Instances are independent
        #expect(manager1.getCacheSize() == 1)
        #expect(manager2.getCacheSize() == 0)
    }

    // MARK: - Add to Cache Tests

    @Test("ImageDataCacheManager addToCache - Stores data in cache")
    func addToCache_StoresDataInCache() {
        // Given
        let cacheManager = ImageDataCacheManager()
        let testData = createTestImageData(width: 100, height: 100)
        let testURL = URL(string: "https://test.com/image.jpg")!

        // When
        cacheManager.addToCache(data: testData, forURL: testURL)

        // Then
        let retrievedData = cacheManager.getFromCache(forURL: testURL)
        #expect(retrievedData != nil)
        #expect(retrievedData?.count == testData.count)
    }

    @Test("ImageDataCacheManager addToCache - Multiple data items can be stored")
    func addToCache_MultipleDataItemsCanBeStored() {
        // Given
        let cacheManager = ImageDataCacheManager()
        let data1 = createTestImageData(width: 50, height: 50)
        let data2 = createTestImageData(width: 100, height: 100)
        let url1 = URL(string: "https://test.com/image1.jpg")!
        let url2 = URL(string: "https://test.com/image2.jpg")!

        // When
        cacheManager.addToCache(data: data1, forURL: url1)
        cacheManager.addToCache(data: data2, forURL: url2)

        // Then
        #expect(cacheManager.getFromCache(forURL: url1) != nil)
        #expect(cacheManager.getFromCache(forURL: url2) != nil)
        #expect(cacheManager.getCacheSize() == 2)
    }

    @Test("ImageDataCacheManager addToCache - Overwrites existing data with same URL")
    func addToCache_OverwritesExistingDataWithSameURL() {
        // Given
        let cacheManager = ImageDataCacheManager()
        let data1 = createTestImageData(width: 50, height: 50)
        let data2 = createTestImageData(width: 100, height: 100)
        let testURL = URL(string: "https://test.com/image.jpg")!

        // When
        cacheManager.addToCache(data: data1, forURL: testURL)
        cacheManager.addToCache(data: data2, forURL: testURL)

        // Then
        let retrievedData = cacheManager.getFromCache(forURL: testURL)
        #expect(retrievedData != nil)
        #expect(retrievedData?.count == data2.count)
        #expect(cacheManager.getCacheSize() == 1) // Still only one entry
    }

    // MARK: - Get from Cache Tests

    @Test("ImageDataCacheManager getFromCache - Returns nil for non-existent URL")
    func getFromCache_ReturnsNilForNonExistentURL() {
        // Given
        let cacheManager = ImageDataCacheManager()
        let nonExistentURL = URL(string: "https://test.com/non-existent.jpg")!

        // When
        let retrievedData = cacheManager.getFromCache(forURL: nonExistentURL)

        // Then
        #expect(retrievedData == nil)
    }

    @Test("ImageDataCacheManager getFromCache - Returns cached data")
    func getFromCache_ReturnsCachedData() {
        // Given
        let cacheManager = ImageDataCacheManager()
        let testData = createTestImageData(width: 100, height: 100)
        let testURL = URL(string: "https://test.com/image.jpg")!

        // When
        cacheManager.addToCache(data: testData, forURL: testURL)
        let retrievedData = cacheManager.getFromCache(forURL: testURL)

        // Then
        #expect(retrievedData != nil)
        #expect(retrievedData?.count == testData.count)
        #expect(retrievedData == testData)
    }

    // MARK: - Remove from Cache Tests

    @Test("ImageDataCacheManager removeFromCache - Removes data from cache")
    func removeFromCache_RemovesDataFromCache() {
        // Given
        let cacheManager = ImageDataCacheManager()
        let testData = createTestImageData(width: 100, height: 100)
        let testURL = URL(string: "https://test.com/image.jpg")!

        cacheManager.addToCache(data: testData, forURL: testURL)
        #expect(cacheManager.getFromCache(forURL: testURL) != nil)

        // When
        cacheManager.removeFromCache(forURL: testURL)

        // Then
        let retrievedData = cacheManager.getFromCache(forURL: testURL)
        #expect(retrievedData == nil)
    }

    @Test("ImageDataCacheManager removeFromCache - Safe to call on non-existent URL")
    func removeFromCache_SafeToCallOnNonExistentURL() {
        // Given
        let cacheManager = ImageDataCacheManager()
        let nonExistentURL = URL(string: "https://test.com/non-existent.jpg")!

        // When & Then - Should not crash
        cacheManager.removeFromCache(forURL: nonExistentURL)
    }

    // MARK: - Clear Cache Tests

    @Test("ImageDataCacheManager clearCache - Removes all data from cache")
    func clearCache_RemovesAllDataFromCache() {
        // Given
        let cacheManager = ImageDataCacheManager()
        let data1 = createTestImageData(width: 50, height: 50)
        let data2 = createTestImageData(width: 100, height: 100)
        let url1 = URL(string: "https://test.com/image1.jpg")!
        let url2 = URL(string: "https://test.com/image2.jpg")!

        cacheManager.addToCache(data: data1, forURL: url1)
        cacheManager.addToCache(data: data2, forURL: url2)

        // When
        cacheManager.clearCache()

        // Then
        #expect(cacheManager.getFromCache(forURL: url1) == nil)
        #expect(cacheManager.getFromCache(forURL: url2) == nil)
        #expect(cacheManager.getCacheSize() == 0)
    }

    // MARK: - Cache Size Tests

    @Test("ImageDataCacheManager getCacheSize - Returns correct cache size")
    func getCacheSize_ReturnsCorrectCacheSize() {
        // Given
        let cacheManager = ImageDataCacheManager()
        let data1 = createTestImageData(width: 50, height: 50)
        let data2 = createTestImageData(width: 100, height: 100)
        let url1 = URL(string: "https://test.com/image1.jpg")!
        let url2 = URL(string: "https://test.com/image2.jpg")!

        // When
        let initialSize = cacheManager.getCacheSize()
        #expect(initialSize == 0)

        cacheManager.addToCache(data: data1, forURL: url1)
        let sizeAfterOne = cacheManager.getCacheSize()
        #expect(sizeAfterOne == 1)

        cacheManager.addToCache(data: data2, forURL: url2)
        let sizeAfterTwo = cacheManager.getCacheSize()
        #expect(sizeAfterTwo == 2)

        cacheManager.removeFromCache(forURL: url1)
        let sizeAfterRemove = cacheManager.getCacheSize()
        #expect(sizeAfterRemove == 1)
    }

    // MARK: - Additional Features Tests

    @Test("ImageDataCacheManager getAccessCount - Returns correct access count")
    func getAccessCount_ReturnsCorrectAccessCount() {
        // Given
        let cacheManager = ImageDataCacheManager()
        let testData = createTestImageData(width: 100, height: 100)
        let testURL = URL(string: "https://test.com/image.jpg")!

        // When
        let initialCount = cacheManager.getAccessCount(forURL: testURL)
        #expect(initialCount == 0)

        cacheManager.addToCache(data: testData, forURL: testURL)
        let countAfterAdd = cacheManager.getAccessCount(forURL: testURL)
        #expect(countAfterAdd == 1)

        let _ = cacheManager.getFromCache(forURL: testURL)
        let countAfterGet = cacheManager.getAccessCount(forURL: testURL)
        #expect(countAfterGet == 2)

        let _ = cacheManager.getFromCache(forURL: testURL)
        let _ = cacheManager.getFromCache(forURL: testURL)
        let countAfterMultipleGets = cacheManager.getAccessCount(forURL: testURL)
        #expect(countAfterMultipleGets == 4)
    }

    @Test("ImageDataCacheManager contains - Returns correct containment status")
    func contains_ReturnsCorrectContainmentStatus() {
        // Given
        let cacheManager = ImageDataCacheManager()
        let testData = createTestImageData(width: 100, height: 100)
        let testURL = URL(string: "https://test.com/image.jpg")!

        // When
        let initialContains = cacheManager.contains(url: testURL)
        #expect(initialContains == false)

        cacheManager.addToCache(data: testData, forURL: testURL)
        let containsAfterAdd = cacheManager.contains(url: testURL)
        #expect(containsAfterAdd == true)

        cacheManager.removeFromCache(forURL: testURL)
        let containsAfterRemove = cacheManager.contains(url: testURL)
        #expect(containsAfterRemove == false)
    }

    @Test("ImageDataCacheManager getMostAccessedURLs - Returns sorted by access count")
    func getMostAccessedURLs_ReturnsSortedByAccessCount() {
        // Given
        let cacheManager = ImageDataCacheManager()
        let data1 = createTestImageData(width: 50, height: 50)
        let data2 = createTestImageData(width: 100, height: 100)
        let data3 = createTestImageData(width: 75, height: 75)
        let url1 = URL(string: "https://test.com/image1.jpg")!
        let url2 = URL(string: "https://test.com/image2.jpg")!
        let url3 = URL(string: "https://test.com/image3.jpg")!

        // When
        cacheManager.addToCache(data: data1, forURL: url1)
        cacheManager.addToCache(data: data2, forURL: url2)
        cacheManager.addToCache(data: data3, forURL: url3)

        // Access with different frequencies
        let _ = cacheManager.getFromCache(forURL: url1)
        let _ = cacheManager.getFromCache(forURL: url1)
        let _ = cacheManager.getFromCache(forURL: url1) // url1: 4 accesses (1 add + 3 gets)

        let _ = cacheManager.getFromCache(forURL: url2) // url2: 2 accesses (1 add + 1 get)

        let _ = cacheManager.getFromCache(forURL: url3)
        let _ = cacheManager.getFromCache(forURL: url3)
        let _ = cacheManager.getFromCache(forURL: url3)
        let _ = cacheManager.getFromCache(forURL: url3) // url3: 5 accesses (1 add + 4 gets)

        let mostAccessed = cacheManager.getMostAccessedURLs()

        // Then
        #expect(mostAccessed.count == 3)
        #expect(mostAccessed[0].url == url3)
        #expect(mostAccessed[0].count == 5)
        #expect(mostAccessed[1].url == url1)
        #expect(mostAccessed[1].count == 4)
        #expect(mostAccessed[2].url == url2)
        #expect(mostAccessed[2].count == 2)
    }

    // MARK: - Integration Tests

    @Test("ImageDataCacheManager - Complete cache workflow")
    func completeCacheWorkflow_WorksCorrectly() {
        // Given
        let cacheManager = ImageDataCacheManager()
        let testData = createTestImageData(width: 100, height: 100)
        let testURL = URL(string: "https://test.com/image.jpg")!

        // Verify cache is empty
        #expect(cacheManager.getFromCache(forURL: testURL) == nil)
        #expect(cacheManager.getCacheSize() == 0)
        #expect(cacheManager.contains(url: testURL) == false)

        // Add data
        cacheManager.addToCache(data: testData, forURL: testURL)
        #expect(cacheManager.getCacheSize() == 1)
        #expect(cacheManager.contains(url: testURL) == true)
        #expect(cacheManager.getAccessCount(forURL: testURL) == 1)

        // Retrieve data
        let retrievedData = cacheManager.getFromCache(forURL: testURL)
        #expect(retrievedData != nil)
        #expect(retrievedData?.count == testData.count)
        #expect(cacheManager.getAccessCount(forURL: testURL) == 2)

        // Remove data
        cacheManager.removeFromCache(forURL: testURL)
        #expect(cacheManager.getFromCache(forURL: testURL) == nil)
        #expect(cacheManager.getCacheSize() == 0)
        #expect(cacheManager.contains(url: testURL) == false)
        #expect(cacheManager.getAccessCount(forURL: testURL) == 0)
    }

    @Test("ImageDataCacheManager - Protocol conformance")
    func protocolConformance_WorksCorrectly() {
        // Given
        let cacheManager: ImageDataCacheProtocol = ImageDataCacheManager()
        let testData = createTestImageData(width: 100, height: 100)
        let testURL = URL(string: "https://test.com/image.jpg")!

        // When - Use through protocol
        cacheManager.addToCache(data: testData, forURL: testURL)
        let retrievedData = cacheManager.getFromCache(forURL: testURL)
        let cacheSize = cacheManager.getCacheSize()

        // Then
        #expect(retrievedData != nil)
        #expect(cacheSize == 1)

        cacheManager.removeFromCache(forURL: testURL)
        #expect(cacheManager.getFromCache(forURL: testURL) == nil)

        cacheManager.clearCache()
        #expect(cacheManager.getCacheSize() == 0)
    }

    @Test("ImageDataCacheManager - Data integrity preserved")
    func dataIntegrity_IsPreserved() {
        // Given
        let cacheManager = ImageDataCacheManager()
        let originalData = createTestImageData(width: 100, height: 100)
        let testURL = URL(string: "https://test.com/image.jpg")!

        // When
        cacheManager.addToCache(data: originalData, forURL: testURL)
        let retrievedData = cacheManager.getFromCache(forURL: testURL)

        // Then - Data should be exactly the same
        #expect(retrievedData != nil)
        #expect(retrievedData == originalData)
        #expect(retrievedData?.count == originalData.count)
    }

    @Test("ImageDataCacheManager - Handles different URL schemes")
    func handledDifferentURLSchemes_WorksCorrectly() {
        // Given
        let cacheManager = ImageDataCacheManager()
        let testData = createTestImageData(width: 100, height: 100)

        let httpsURL = URL(string: "https://test.com/image.jpg")!
        let httpURL = URL(string: "http://test.com/image.jpg")!
        let fileURL = URL(string: "file:///path/to/image.jpg")!

        // When
        cacheManager.addToCache(data: testData, forURL: httpsURL)
        cacheManager.addToCache(data: testData, forURL: httpURL)
        cacheManager.addToCache(data: testData, forURL: fileURL)

        // Then - All URLs should be cached independently
        #expect(cacheManager.contains(url: httpsURL) == true)
        #expect(cacheManager.contains(url: httpURL) == true)
        #expect(cacheManager.contains(url: fileURL) == true)
        #expect(cacheManager.getCacheSize() == 3)
    }

    @Test("ImageDataCacheManager - Dependency injection in tests")
    func dependencyInjection_WorksInTests() {
        // Given - Can create multiple independent instances for testing
        let testCache1 = ImageDataCacheManager(countLimit: 10, totalCostLimit: 10 * 1024 * 1024)
        let testCache2 = ImageDataCacheManager(countLimit: 20, totalCostLimit: 20 * 1024 * 1024)

        let testData = createTestImageData(width: 100, height: 100)
        let testURL = URL(string: "https://test.com/image.jpg")!

        // When
        testCache1.addToCache(data: testData, forURL: testURL)
        testCache2.addToCache(data: testData, forURL: testURL)

        // Then - Both caches work independently
        #expect(testCache1.getCacheSize() == 1)
        #expect(testCache2.getCacheSize() == 1)

        testCache1.clearCache()
        #expect(testCache1.getCacheSize() == 0)
        #expect(testCache2.getCacheSize() == 1) // testCache2 unaffected
    }

    // MARK: - Helper Methods

    private func createTestImageData(width: CGFloat, height: CGFloat) -> Data {
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(CGRect(origin: .zero, size: size))

        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        return image.pngData() ?? Data()
    }
}
