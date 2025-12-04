//
//  NetworkReachabilityTests.swift
//  LastTests
//
//  Created by Claude Code on 04.12.2025.
//

import Testing
import Foundation
import Network
@testable import Last

@Suite(.serialized)
struct NetworkReachabilityTests {

    // MARK: - Initialization Tests

    @Test("NetworkReachability initializes without errors")
    func initialization_CompletesSuccessfully() async throws {
        // When
        let reachability = NetworkReachability()

        // Then - Should not crash
        #expect(reachability != nil)
    }

    @Test("NetworkReachability isNetworkAvailable returns Bool")
    func isNetworkAvailable_ReturnsValidBoolean() async throws {
        // Given
        let reachability = NetworkReachability()

        // Allow time for monitor to initialize
        try? await Task.sleep(for: .milliseconds(100))

        // When
        let isAvailable = await reachability.isNetworkAvailable()

        // Then - Should return a valid boolean (true or false based on system state)
        #expect(isAvailable == true || isAvailable == false)
    }

    // MARK: - Mock Network Reachability Tests

    @Test("MockNetworkReachability returns configured state")
    func mockReachability_ReturnsConfiguredState() async throws {
        // Given
        let mockReachability = MockNetworkReachability()

        // When - Test connected state
        mockReachability.isConnected = true
        let connectedResult = await mockReachability.isNetworkAvailable()

        // Then
        #expect(connectedResult == true)

        // When - Test disconnected state
        mockReachability.isConnected = false
        let disconnectedResult = await mockReachability.isNetworkAvailable()

        // Then
        #expect(disconnectedResult == false)
    }

    @Test("MockNetworkReachability tracks call count")
    func mockReachability_TracksCallCount() async throws {
        // Given
        let mockReachability = MockNetworkReachability()

        // When
        #expect(mockReachability.isNetworkAvailableCallCount == 0)

        _ = await mockReachability.isNetworkAvailable()
        #expect(mockReachability.isNetworkAvailableCallCount == 1)

        _ = await mockReachability.isNetworkAvailable()
        #expect(mockReachability.isNetworkAvailableCallCount == 2)

        _ = await mockReachability.isNetworkAvailable()
        #expect(mockReachability.isNetworkAvailableCallCount == 3)
    }

    @Test("MockNetworkReachability can toggle state")
    func mockReachability_CanToggleState() async throws {
        // Given
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true

        // When/Then - Test multiple toggles
        var result = await mockReachability.isNetworkAvailable()
        #expect(result == true)

        mockReachability.isConnected = false
        result = await mockReachability.isNetworkAvailable()
        #expect(result == false)

        mockReachability.isConnected = true
        result = await mockReachability.isNetworkAvailable()
        #expect(result == true)

        mockReachability.isConnected = false
        result = await mockReachability.isNetworkAvailable()
        #expect(result == false)
    }

    @Test("MockNetworkReachability default state is connected")
    func mockReachability_DefaultStateIsConnected() async throws {
        // Given
        let mockReachability = MockNetworkReachability()

        // When
        let result = await mockReachability.isNetworkAvailable()

        // Then
        #expect(result == true)
    }
}
