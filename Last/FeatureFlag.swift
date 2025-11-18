//
//  FeatureFlag.swift
//  Last
//
//  Feature flag management for gradual feature rollout
//

import Foundation

// MARK: - Feature Flag Enum

/// Enumeration of available feature flags in the application
/// 
/// ## Adding a New Feature Flag
/// 
/// To add a new feature flag:
/// 1. Add a new case to the enum following `camelCase` naming convention
/// 2. Add a description in the `description` computed property
/// 3. Add the flag to `defaultStates` in `FeatureFlagManager` (default: `false` for safety)
/// 4. Use the flag in your code: `featureFlagManager.isEnabled(.yourNewFlag)`
/// 
/// Example:
/// ```swift
/// enum FeatureFlag: String, CaseIterable {
///     case enhancedCarousel = "enhancedCarousel"
///     case newFeature = "newFeature"  // Add new case
///     
///     var description: String {
///         switch self {
///         case .enhancedCarousel: return "..."
///         case .newFeature: return "Description of new feature"  // Add description
///         }
///     }
/// }
/// ```
enum FeatureFlag: String, CaseIterable {
    /// Enhanced carousel view with advanced customization options
    case enhancedCarousel = "enhancedCarousel"
    
    /// Generic carousel view that works with any data type and custom content
    case genericCarousel = "genericCarousel"
    
    /// Returns a user-friendly description of the feature flag
    var description: String {
        switch self {
        case .enhancedCarousel:
            return "Enhanced Carousel View with advanced customization, animations, and accessibility features"
        case .genericCarousel:
            return "Generic Carousel View that works with any data type and provides flexible custom content builders"
        }
    }
}

// MARK: - Feature Flag Manager Protocol

/// Protocol for managing feature flags
/// 
/// ## Usage Example
/// ```swift
/// let manager = FeatureFlagManager.shared
/// if manager.isEnabled(.enhancedCarousel) {
///     // Use enhanced carousel
/// }
/// ```
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
    
    /// Returns all feature flag states as a dictionary
    /// - Returns: Dictionary mapping each flag to its enabled state
    func getAllFlagStates() -> [FeatureFlag: Bool]
    
    /// Resets a feature flag to its default state
    /// - Parameter flag: The feature flag to reset
    func resetToDefault(_ flag: FeatureFlag)
    
    /// Resets all feature flags to their default states
    func resetAllToDefaults()
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
        .enhancedCarousel: false,
        .genericCarousel: false
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
    
    func getAllFlagStates() -> [FeatureFlag: Bool] {
        var states: [FeatureFlag: Bool] = [:]
        for flag in FeatureFlag.allCases {
            states[flag] = isEnabled(flag)
        }
        return states
    }
    
    func resetToDefault(_ flag: FeatureFlag) {
        let key = userDefaultsPrefix + flag.rawValue
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    func resetAllToDefaults() {
        for flag in FeatureFlag.allCases {
            resetToDefault(flag)
        }
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
    
    func getAllFlagStates() -> [FeatureFlag: Bool] {
        var states: [FeatureFlag: Bool] = [:]
        for flag in FeatureFlag.allCases {
            states[flag] = isEnabled(flag)
        }
        return states
    }
    
    func resetToDefault(_ flag: FeatureFlag) {
        flagStates.removeValue(forKey: flag)
    }
    
    func resetAllToDefaults() {
        flagStates.removeAll()
    }
}

