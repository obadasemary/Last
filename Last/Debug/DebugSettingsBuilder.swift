//
//  DebugSettingsBuilder.swift
//  Last
//
//  Builder for DebugSettingsView following Clean Architecture pattern
//

import Foundation
import SwiftUI

final class DebugSettingsBuilder {
    
    /// Builds the DebugSettingsView with dependencies
    /// - Parameters:
    ///   - featureFlagManager: Optional feature flag manager (defaults to shared instance)
    ///   - colorSchemeManager: Optional color scheme manager (defaults to shared instance)
    /// - Returns: A configured DebugSettingsView
    func buildDebugSettingsView(
        featureFlagManager: FeatureFlagManagerProtocol = FeatureFlagManager.shared,
        colorSchemeManager: ColorSchemeManagerProtocol = ColorSchemeManager.shared
    ) -> some View {
        let viewModel = DebugSettingsViewModel(
            featureFlagManager: featureFlagManager,
            colorSchemeManager: colorSchemeManager
        )
        return DebugSettingsView(viewModel: viewModel)
    }
}

