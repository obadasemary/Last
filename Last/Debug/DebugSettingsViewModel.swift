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
    
    // Store the concrete ColorSchemeManager if available for observation
    // This allows the viewModel to observe changes to the manager
    private var observableColorSchemeManager: ColorSchemeManager?
    
    private(set) var featureFlagStates: [FeatureFlag: Bool] = [:]
    var showingResetAlert = false
    
    /// Color scheme preference for the picker binding
    /// This property mirrors the manager's state and triggers view updates when changed
    var colorSchemePreference: ColorSchemeOption = .system
    
    /// Current preferred color scheme (nil = system default)
    /// This property triggers view updates when changed
    var preferredColorScheme: ColorScheme? {
        get {
            // If we have the observable manager, read from it directly for reactive updates
            if let observableManager = observableColorSchemeManager {
                return observableManager.preferredColorScheme
            }
            return colorSchemeManager.getPreferredColorScheme()
        }
        set {
            colorSchemeManager.setPreferredColorScheme(newValue)
            // Trigger update by accessing the observable property
            if let observableManager = observableColorSchemeManager {
                observableManager.preferredColorScheme = newValue
            }
        }
    }
    
    // MARK: - Initialization
    
    init(
        featureFlagManager: FeatureFlagManagerProtocol,
        colorSchemeManager: ColorSchemeManagerProtocol = ColorSchemeManager.shared
    ) {
        self.featureFlagManager = featureFlagManager
        self.colorSchemeManager = colorSchemeManager
        // Store the concrete type if it's ColorSchemeManager for observation
        self.observableColorSchemeManager = colorSchemeManager as? ColorSchemeManager
    }
    
    // MARK: - Public Methods
    
    /// Loads all feature flag states from the manager
    func loadFeatureFlagStates() {
        featureFlagStates = featureFlagManager.getAllFlagStates()
        // Sync color scheme preference with manager
        colorSchemePreference = ColorSchemeOption(colorScheme: preferredColorScheme) ?? .system
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
    
    /// Handles color scheme preference changes
    /// - Parameters:
    ///   - oldValue: The previous color scheme preference
    ///   - newValue: The new color scheme preference
    func handleColorSchemeChange(oldValue: ColorSchemeOption, newValue: ColorSchemeOption) {
        // Update the manager with the new preference
        preferredColorScheme = newValue.colorScheme
    }
}

