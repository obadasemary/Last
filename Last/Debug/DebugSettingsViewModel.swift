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
    func resetAllFlags() {
        for flag in FeatureFlag.allCases {
            // Reset to default (false for all flags currently)
            featureFlagManager.setEnabled(flag, enabled: false)
            featureFlagStates[flag] = false
        }
    }
    
    /// Generates a string representation of all feature flag states
    /// - Returns: A formatted string with all flag states
    func generateFlagsStatusString() -> String {
        var flagsString = "Feature Flags Status:\n\n"
        for flag in FeatureFlag.allCases {
            let status = featureFlagManager.isEnabled(flag) ? "✅ Enabled" : "❌ Disabled"
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

