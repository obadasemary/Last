//
//  DebugSettingsViewModel.swift
//  Last
//
//  ViewModel for DebugSettingsView following Clean Architecture
//

import Foundation
import SwiftUI

@Observable
final class DebugSettingsViewModel {
    
    // MARK: - Properties
    
    private let featureFlagManager: FeatureFlagManagerProtocol
    private let colorSchemeManager: ColorSchemeManagerProtocol
    
    private(set) var featureFlagStates: [FeatureFlag: Bool] = [:]
    var showingResetAlert = false
    
    /// Current preferred color scheme (nil = system default)
    /// This property triggers view updates when changed
    var preferredColorScheme: ColorScheme? {
        get {
            colorSchemeManager.getPreferredColorScheme()
        }
        set {
            colorSchemeManager.setPreferredColorScheme(newValue)
        }
    }
    
    // MARK: - Initialization
    
    init(
        featureFlagManager: FeatureFlagManagerProtocol,
        colorSchemeManager: ColorSchemeManagerProtocol = ColorSchemeManager.shared
    ) {
        self.featureFlagManager = featureFlagManager
        self.colorSchemeManager = colorSchemeManager
    }
    
    // MARK: - Public Methods
    
    /// Loads all feature flag states from the manager
    func loadFeatureFlagStates() {
        featureFlagStates = featureFlagManager.getAllFlagStates()
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
        featureFlagManager.resetAllToDefaults()
        // Reload states to reflect default values
        featureFlagStates = featureFlagManager.getAllFlagStates()
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

