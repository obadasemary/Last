//
//  MockNetworkReachability.swift
//  LastTests
//
//  Created by Claude Code on 04.12.2025.
//

import Foundation
@testable import Last

final class MockNetworkReachability: NetworkReachabilityProtocol {
    var isConnected = true
    var isNetworkAvailableCallCount = 0

    func isNetworkAvailable() async -> Bool {
        isNetworkAvailableCallCount += 1
        return isConnected
    }
}
