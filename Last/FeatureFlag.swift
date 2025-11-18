//
//  FeatureFlag.swift
//  Last
//
//  Feature flag management for gradual feature rollout
//

import Foundation

// MARK: - Feature Flag Enum

/// Enumeration of available feature flags in the application
enum FeatureFlag: String, CaseIterable {
    /// Enhanced carousel view with advanced customization options
    case enhancedCarousel = "enhancedCarousel"
    
    /// Returns a user-friendly description of the feature flag
    var description: String {
        switch self {
        case .enhancedCarousel:
            return "Enhanced Carousel View with advanced customization, animations, and accessibility features"
        }
    }
}

// MARK: - Feature Flag Manager Protocol

/// Protocol for managing feature flags
protocol FeatureFlagManagerProtocol {
    /// Checks if a feature flag is enabled
    /// - Parameter flag: The feature flag to check
    /// - Returns: `true` if the flag is enabled, `false` otherwise
    func isEnabled(_ flag: FeatureFlag) -> Bool
    
    /// Sets the enabled state of a feature flag
    /// - Parameters:
    ///   - flag: The feature flag to set
    ///   - enabled: Whether the flag should be enabled
    func setEnabled(_ flag: FeatureFlag, enabled: Bool)
}

// MARK: - Feature Flag Manager

/// Default implementation of feature flag management
final class FeatureFlagManager: FeatureFlagManagerProtocol {
    
    // MARK: - Properties
    
    /// Shared instance for app-wide feature flag management
    static let shared = FeatureFlagManager()
    
    /// UserDefaults key prefix for storing feature flag states
    private let userDefaultsPrefix = "featureFlag_"
    
    /// Default flag states (safe defaults - all disabled by default)
    private let defaultStates: [FeatureFlag: Bool] = [
        .enhancedCarousel: false
    ]
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Feature Flag Manager Protocol
    
    func isEnabled(_ flag: FeatureFlag) -> Bool {
        // Check UserDefaults for overridden value
        let key = userDefaultsPrefix + flag.rawValue
        if UserDefaults.standard.object(forKey: key) != nil {
            return UserDefaults.standard.bool(forKey: key)
        }
        
        // Return default state
        return defaultStates[flag] ?? false
    }
    
    func setEnabled(_ flag: FeatureFlag, enabled: Bool) {
        let key = userDefaultsPrefix + flag.rawValue
        UserDefaults.standard.set(enabled, forKey: key)
    }
}

// MARK: - Mock Feature Flag Manager

/// Mock implementation for testing and previews
final class MockFeatureFlagManager: FeatureFlagManagerProtocol {
    
    /// Dictionary to store flag states
    private var flagStates: [FeatureFlag: Bool] = [:]
    
    /// Initializes with default flag states
    /// - Parameter defaultStates: Dictionary of default flag states
    init(defaultStates: [FeatureFlag: Bool] = [:]) {
        self.flagStates = defaultStates
    }
    
    func isEnabled(_ flag: FeatureFlag) -> Bool {
        return flagStates[flag] ?? false
    }
    
    func setEnabled(_ flag: FeatureFlag, enabled: Bool) {
        flagStates[flag] = enabled
    }
}

