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
    /// - Parameter featureFlagManager: Optional feature flag manager (defaults to shared instance)
    /// - Returns: A configured DebugSettingsView
    func buildDebugSettingsView(
        featureFlagManager: FeatureFlagManagerProtocol = FeatureFlagManager.shared
    ) -> some View {
        let viewModel = DebugSettingsViewModel(featureFlagManager: featureFlagManager)
        return DebugSettingsView(viewModel: viewModel)
    }
}

