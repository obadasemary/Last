//
//  FeedDetailsViewModelTests.swift
//  LastTests
//
//  Created by Claude Code
//

import Testing
import Foundation
import UIKit
@testable import Last

@Suite(.serialized)
struct FeedDetailsViewModelTests {

    // MARK: - Initialization Tests

    @MainActor
    @Test("FeedDetailsViewModel initialization - Sets character correctly")
    func initialization_SetsCharacterCorrectly() {
        // Given
        let character = CharactersResponse(
            id: 1,
            name: "Test Character",
            species: "Human",
            image: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
        )

        // When
        let viewModel = FeedDetailsViewModel(character: character)

        // Then
        #expect(viewModel.character.id == character.id)
        #expect(viewModel.character.name == character.name)
        #expect(viewModel.character.species == character.species)
        #expect(viewModel.character.image == character.image)
        #expect(viewModel.brightness == 0.75) // Default brightness
        #expect(viewModel.cachedImage == nil) // Initially no cached image
    }

    @MainActor
    @Test("FeedDetailsViewModel initialization - Handles character without image")
    func initialization_HandlesCharacterWithoutImage() {
        // Given
        let character = CharactersResponse(
            id: 2,
            name: "Test Character",
            species: "Alien",
            image: nil
        )

        // When
        let viewModel = FeedDetailsViewModel(character: character)

        // Then
        #expect(viewModel.character.image == nil)
        #expect(viewModel.brightness == 0.75)
    }

    // MARK: - Brightness Tests

    @MainActor
    @Test("FeedDetailsViewModel updateBrightness - Updates brightness value")
    func updateBrightness_UpdatesBrightnessValue() {
        // Given
        let character = CharactersResponse(
            id: 1,
            name: "Test",
            species: "Human",
            image: URL(string: "https://test.com/image.jpeg")
        )
        let viewModel = FeedDetailsViewModel(character: character)
        let newBrightness: CGFloat = 0.5

        // When
        viewModel.updateBrightness(newBrightness)

        // Then
        #expect(viewModel.brightness == newBrightness)
    }

    @MainActor
    @Test("FeedDetailsViewModel updateBrightness - Handles minimum value")
    func updateBrightness_HandlesMinimumValue() {
        // Given
        let character = CharactersResponse(
            id: 1,
            name: "Test",
            species: "Human",
            image: URL(string: "https://test.com/image.jpeg")
        )
        let viewModel = FeedDetailsViewModel(character: character)
        let minBrightness: CGFloat = 0.0

        // When
        viewModel.updateBrightness(minBrightness)

        // Then
        #expect(viewModel.brightness == minBrightness)
    }

    @MainActor
    @Test("FeedDetailsViewModel updateBrightness - Handles maximum value")
    func updateBrightness_HandlesMaximumValue() {
        // Given
        let character = CharactersResponse(
            id: 1,
            name: "Test",
            species: "Human",
            image: URL(string: "https://test.com/image.jpeg")
        )
        let viewModel = FeedDetailsViewModel(character: character)
        let maxBrightness: CGFloat = 1.0

        // When
        viewModel.updateBrightness(maxBrightness)

        // Then
        #expect(viewModel.brightness == maxBrightness)
    }

    @MainActor
    @Test("FeedDetailsViewModel updateBrightness - Multiple updates work correctly")
    func updateBrightness_MultipleUpdatesWorkCorrectly() {
        // Given
        let character = CharactersResponse(
            id: 1,
            name: "Test",
            species: "Human",
            image: URL(string: "https://test.com/image.jpeg")
        )
        let viewModel = FeedDetailsViewModel(character: character)

        // When
        viewModel.updateBrightness(0.3)
        #expect(viewModel.brightness == 0.3)

        viewModel.updateBrightness(0.7)
        #expect(viewModel.brightness == 0.7)

        viewModel.updateBrightness(0.9)
        #expect(viewModel.brightness == 0.9)

        // Then - Final value is correct
        #expect(viewModel.brightness == 0.9)
    }

    // MARK: - Cache Save Tests

    @MainActor
    @Test("FeedDetailsViewModel saveToCache - Saves image to cache")
    func saveToCache_SavesImageToCache() {
        // Given
        let imageURL = URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!
        let character = CharactersResponse(
            id: 1,
            name: "Test",
            species: "Human",
            image: imageURL
        )
        let viewModel = FeedDetailsViewModel(character: character)
        let testImage = createTestImage()

        // Clear cache first
        viewModel.removeFromCache()

        // When
        viewModel.saveToCache(image: testImage)

        // Then - Verify image was saved by retrieving it
        let cachedImage = viewModel.getFromCache()
        #expect(cachedImage != nil)
    }

    @MainActor
    @Test("FeedDetailsViewModel saveToCache - Does nothing when character has no image URL")
    func saveToCache_DoesNothingWhenCharacterHasNoImageURL() {
        // Given
        let character = CharactersResponse(
            id: 1,
            name: "Test",
            species: "Human",
            image: nil
        )
        let viewModel = FeedDetailsViewModel(character: character)
        let testImage = createTestImage()

        // When
        viewModel.saveToCache(image: testImage)

        // Then - Should not crash and cache should remain empty
        let cachedImage = viewModel.getFromCache()
        #expect(cachedImage == nil)
    }

    // MARK: - Cache Get Tests

    @MainActor
    @Test("FeedDetailsViewModel getFromCache - Returns nil when cache is empty")
    func getFromCache_ReturnsNilWhenCacheIsEmpty() {
        // Given
        let character = CharactersResponse(
            id: 1,
            name: "Test",
            species: "Human",
            image: URL(string: "https://test.com/image.jpeg")
        )
        let viewModel = FeedDetailsViewModel(character: character)

        // Clear cache first
        viewModel.removeFromCache()

        // When
        let cachedImage = viewModel.getFromCache()

        // Then
        #expect(cachedImage == nil)
        #expect(viewModel.cachedImage == nil)
    }

    @MainActor
    @Test("FeedDetailsViewModel getFromCache - Returns cached image when available")
    func getFromCache_ReturnsCachedImageWhenAvailable() {
        // Given
        let imageURL = URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!
        let character = CharactersResponse(
            id: 1,
            name: "Test",
            species: "Human",
            image: imageURL
        )
        let viewModel = FeedDetailsViewModel(character: character)
        let testImage = createTestImage()

        // Clear cache and save image
        viewModel.removeFromCache()
        viewModel.saveToCache(image: testImage)

        // When
        let cachedImage = viewModel.getFromCache()

        // Then
        #expect(cachedImage != nil)
        #expect(viewModel.cachedImage != nil)
    }

    @MainActor
    @Test("FeedDetailsViewModel getFromCache - Updates cachedImage property")
    func getFromCache_UpdatesCachedImageProperty() {
        // Given
        let imageURL = URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!
        let character = CharactersResponse(
            id: 1,
            name: "Test",
            species: "Human",
            image: imageURL
        )
        let viewModel = FeedDetailsViewModel(character: character)
        let testImage = createTestImage()

        // Clear cache and save image
        viewModel.removeFromCache()
        viewModel.saveToCache(image: testImage)

        // Verify initial state
        #expect(viewModel.cachedImage == nil)

        // When
        let _ = viewModel.getFromCache()

        // Then
        #expect(viewModel.cachedImage != nil)
    }

    @MainActor
    @Test("FeedDetailsViewModel getFromCache - Returns nil when character has no image URL")
    func getFromCache_ReturnsNilWhenCharacterHasNoImageURL() {
        // Given
        let character = CharactersResponse(
            id: 1,
            name: "Test",
            species: "Human",
            image: nil
        )
        let viewModel = FeedDetailsViewModel(character: character)

        // When
        let cachedImage = viewModel.getFromCache()

        // Then
        #expect(cachedImage == nil)
        #expect(viewModel.cachedImage == nil)
    }

    // MARK: - Cache Remove Tests

    @MainActor
    @Test("FeedDetailsViewModel removeFromCache - Removes image from cache")
    func removeFromCache_RemovesImageFromCache() {
        // Given
        let imageURL = URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!
        let character = CharactersResponse(
            id: 1,
            name: "Test",
            species: "Human",
            image: imageURL
        )
        let viewModel = FeedDetailsViewModel(character: character)
        let testImage = createTestImage()

        // Save image first
        viewModel.saveToCache(image: testImage)
        #expect(viewModel.getFromCache() != nil)

        // When
        viewModel.removeFromCache()

        // Then
        let cachedImage = viewModel.getFromCache()
        #expect(cachedImage == nil)
    }

    @MainActor
    @Test("FeedDetailsViewModel removeFromCache - Does nothing when character has no image URL")
    func removeFromCache_DoesNothingWhenCharacterHasNoImageURL() {
        // Given
        let character = CharactersResponse(
            id: 1,
            name: "Test",
            species: "Human",
            image: nil
        )
        let viewModel = FeedDetailsViewModel(character: character)

        // When - Should not crash
        viewModel.removeFromCache()

        // Then - No error occurred
        #expect(viewModel.character.image == nil)
    }

    @MainActor
    @Test("FeedDetailsViewModel removeFromCache - Safe to call multiple times")
    func removeFromCache_SafeToCallMultipleTimes() {
        // Given
        let imageURL = URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!
        let character = CharactersResponse(
            id: 1,
            name: "Test",
            species: "Human",
            image: imageURL
        )
        let viewModel = FeedDetailsViewModel(character: character)

        // When - Call remove multiple times
        viewModel.removeFromCache()
        viewModel.removeFromCache()
        viewModel.removeFromCache()

        // Then - Should not crash
        let cachedImage = viewModel.getFromCache()
        #expect(cachedImage == nil)
    }

    // MARK: - Integration Tests

    @MainActor
    @Test("FeedDetailsViewModel - Complete cache workflow")
    func completeCacheWorkflow_WorksCorrectly() {
        // Given
        let imageURL = URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!
        let character = CharactersResponse(
            id: 1,
            name: "Test",
            species: "Human",
            image: imageURL
        )
        let viewModel = FeedDetailsViewModel(character: character)
        let testImage = createTestImage()

        // Clear cache
        viewModel.removeFromCache()
        #expect(viewModel.getFromCache() == nil)

        // Save image
        viewModel.saveToCache(image: testImage)

        // Retrieve image
        let retrievedImage = viewModel.getFromCache()
        #expect(retrievedImage != nil)
        #expect(viewModel.cachedImage != nil)

        // Remove image
        viewModel.removeFromCache()
        #expect(viewModel.getFromCache() == nil)
    }

    @MainActor
    @Test("FeedDetailsViewModel - Brightness and cache operations are independent")
    func brightnessAndCacheOperations_AreIndependent() {
        // Given
        let imageURL = URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!
        let character = CharactersResponse(
            id: 1,
            name: "Test",
            species: "Human",
            image: imageURL
        )
        let viewModel = FeedDetailsViewModel(character: character)
        let testImage = createTestImage()

        // When - Update brightness
        viewModel.updateBrightness(0.5)
        #expect(viewModel.brightness == 0.5)

        // Save to cache
        viewModel.saveToCache(image: testImage)
        let cachedImage = viewModel.getFromCache()
        #expect(cachedImage != nil)

        // Update brightness again
        viewModel.updateBrightness(0.8)
        #expect(viewModel.brightness == 0.8)

        // Then - Cache should still work
        let cachedImageAfterBrightnessChange = viewModel.getFromCache()
        #expect(cachedImageAfterBrightnessChange != nil)
        #expect(viewModel.brightness == 0.8)
    }

    // MARK: - Helper Methods

    private func createTestImage() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}

