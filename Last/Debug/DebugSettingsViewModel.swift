//
//  DebugSettingsViewModel.swift
//  Last
//
//  ViewModel for DebugSettingsView following Clean Architecture
//

import Foundation

@Observable
final class DebugSettingsViewModel {
    
    // MARK: - Properties
    
    private let featureFlagManager: FeatureFlagManagerProtocol
    
    private(set) var featureFlagStates: [FeatureFlag: Bool] = [:]
    var showingResetAlert = false
    
    // MARK: - Initialization
    
    init(featureFlagManager: FeatureFlagManagerProtocol) {
        self.featureFlagManager = featureFlagManager
    }
    
    // MARK: - Public Methods
    
    /// Loads all feature flag states from the manager
    func loadFeatureFlagStates() {
        for flag in FeatureFlag.allCases {
            featureFlagStates[flag] = featureFlagManager.isEnabled(flag)
        }
    }
    
    /// Sets the enabled state for a specific feature flag
    /// - Parameters:
    ///   - flag: The feature flag to update
    ///   - enabled: Whether the flag should be enabled
    func setFeatureFlag(_ flag: FeatureFlag, enabled: Bool) {
        featureFlagStates[flag] = enabled
        featureFlagManager.setEnabled(flag, enabled: enabled)
    }
    
    /// Resets all feature flags to their default values
    /// Removes UserDefaults overrides to restore default states
    func resetAllFlags() {
        for flag in FeatureFlag.allCases {
            // Remove UserDefaults override to restore default value
            // This works for FeatureFlagManager by removing the key
            // For MockFeatureFlagManager, we'll set to false (mock defaults)
            resetFlagToDefault(flag)
            // Reload state to reflect default value
            featureFlagStates[flag] = featureFlagManager.isEnabled(flag)
        }
    }
    
    /// Resets a single flag to its default value by removing UserDefaults override
    /// For FeatureFlagManager: Removes UserDefaults key to restore default
    /// For MockFeatureFlagManager: Sets to false (mock doesn't support defaults restoration)
    /// - Parameter flag: The feature flag to reset
    private func resetFlagToDefault(_ flag: FeatureFlag) {
        // Check if this is the real FeatureFlagManager (uses UserDefaults)
        if featureFlagManager is FeatureFlagManager {
            let key = "featureFlag_" + flag.rawValue
            UserDefaults.standard.removeObject(forKey: key)
        } else {
            // For MockFeatureFlagManager, set to false (mock default)
            // Note: This doesn't restore actual mock defaults, but is acceptable for testing
            featureFlagManager.setEnabled(flag, enabled: false)
        }
    }
    
    /// Generates a string representation of all feature flag states
    /// - Returns: A formatted string with all flag states
    func generateFlagsStatusString() -> String {
        var flagsString = "Feature Flags Status:\n\n"
        for flag in FeatureFlag.allCases {
            let status = isFlagEnabled(flag) ? "✅ Enabled" : "❌ Disabled"
            flagsString += "\(flag.rawValue): \(status)\n"
            flagsString += "  \(flag.description)\n\n"
        }
        return flagsString
    }
    
    /// Gets the enabled state for a specific feature flag
    /// - Parameter flag: The feature flag to check
    /// - Returns: `true` if enabled, `false` otherwise
    func isFlagEnabled(_ flag: FeatureFlag) -> Bool {
        return featureFlagStates[flag] ?? false
    }
}

