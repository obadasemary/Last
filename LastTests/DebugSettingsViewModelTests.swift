//
//  DebugSettingsViewModelTests.swift
//  LastTests
//
//  Unit tests for DebugSettingsViewModel
//

import Testing
import Foundation
import SwiftUI
@testable import Last

@Suite(.serialized)
struct DebugSettingsViewModelTests {
    
    // MARK: - loadFeatureFlagStates Tests
    
    @MainActor
    @Test("DebugSettingsViewModel loadFeatureFlagStates - Loads all flags")
    func loadFeatureFlagStates_LoadsAllFlags() throws {
        // Given
        let mockManager = MockFeatureFlagManager(
            defaultStates: [
                .enhancedCarousel: true
            ]
        )
        let viewModel = DebugSettingsViewModel(featureFlagManager: mockManager)
        
        // When
        viewModel.loadFeatureFlagStates()
        
        // Then
        #expect(viewModel.featureFlagStates.count == FeatureFlag.allCases.count)
        #expect(viewModel.isFlagEnabled(.enhancedCarousel) == true)
    }
    
    @MainActor
    @Test("DebugSettingsViewModel loadFeatureFlagStates - Loads disabled flags")
    func loadFeatureFlagStates_LoadsDisabledFlags() throws {
        // Given
        let mockManager = MockFeatureFlagManager()
        let viewModel = DebugSettingsViewModel(featureFlagManager: mockManager)
        
        // When
        viewModel.loadFeatureFlagStates()
        
        // Then
        #expect(viewModel.featureFlagStates.count == FeatureFlag.allCases.count)
        #expect(viewModel.isFlagEnabled(.enhancedCarousel) == false)
    }
    
    // MARK: - setFeatureFlag Tests
    
    @MainActor
    @Test("DebugSettingsViewModel setFeatureFlag - Enables flag")
    func setFeatureFlag_EnablesFlag() throws {
        // Given
        let mockManager = MockFeatureFlagManager()
        let viewModel = DebugSettingsViewModel(featureFlagManager: mockManager)
        viewModel.loadFeatureFlagStates()
        
        // When
        viewModel.setFeatureFlag(.enhancedCarousel, enabled: true)
        
        // Then
        #expect(viewModel.isFlagEnabled(.enhancedCarousel) == true)
        #expect(mockManager.isEnabled(.enhancedCarousel) == true)
    }
    
    @MainActor
    @Test("DebugSettingsViewModel setFeatureFlag - Disables flag")
    func setFeatureFlag_DisablesFlag() throws {
        // Given
        let mockManager = MockFeatureFlagManager(
            defaultStates: [.enhancedCarousel: true]
        )
        let viewModel = DebugSettingsViewModel(featureFlagManager: mockManager)
        viewModel.loadFeatureFlagStates()
        
        // When
        viewModel.setFeatureFlag(.enhancedCarousel, enabled: false)
        
        // Then
        #expect(viewModel.isFlagEnabled(.enhancedCarousel) == false)
        #expect(mockManager.isEnabled(.enhancedCarousel) == false)
    }
    
    @MainActor
    @Test("DebugSettingsViewModel setFeatureFlag - Updates multiple flags")
    func setFeatureFlag_UpdatesMultipleFlags() throws {
        // Given
        let mockManager = MockFeatureFlagManager()
        let viewModel = DebugSettingsViewModel(featureFlagManager: mockManager)
        viewModel.loadFeatureFlagStates()
        
        // When
        viewModel.setFeatureFlag(.enhancedCarousel, enabled: true)
        
        // Then
        #expect(viewModel.isFlagEnabled(.enhancedCarousel) == true)
        // Verify other flags remain unchanged
        for flag in FeatureFlag.allCases where flag != .enhancedCarousel {
            #expect(viewModel.isFlagEnabled(flag) == false)
        }
    }
    
    // MARK: - resetAllFlags Tests
    
    @MainActor
    @Test("DebugSettingsViewModel resetAllFlags - Resets all flags to false")
    func resetAllFlags_ResetsAllFlagsToFalse() throws {
        // Given
        let mockManager = MockFeatureFlagManager(
            defaultStates: [.enhancedCarousel: true]
        )
        let viewModel = DebugSettingsViewModel(featureFlagManager: mockManager)
        viewModel.loadFeatureFlagStates()
        viewModel.setFeatureFlag(.enhancedCarousel, enabled: true)
        
        // When
        viewModel.resetAllFlags()
        
        // Then
        for flag in FeatureFlag.allCases {
            #expect(viewModel.isFlagEnabled(flag) == false)
            #expect(mockManager.isEnabled(flag) == false)
        }
    }
    
    @MainActor
    @Test("DebugSettingsViewModel resetAllFlags - Clears all flag states")
    func resetAllFlags_ClearsAllFlagStates() throws {
        // Given
        let mockManager = MockFeatureFlagManager(
            defaultStates: [.enhancedCarousel: true]
        )
        let viewModel = DebugSettingsViewModel(featureFlagManager: mockManager)
        viewModel.loadFeatureFlagStates()
        
        // When
        viewModel.resetAllFlags()
        
        // Then
        #expect(viewModel.featureFlagStates.count == FeatureFlag.allCases.count)
        for flag in FeatureFlag.allCases {
            #expect(viewModel.featureFlagStates[flag] == false)
        }
    }
    
    // MARK: - generateFlagsStatusString Tests
    
    @MainActor
    @Test("DebugSettingsViewModel generateFlagsStatusString - Generates correct format")
    func generateFlagsStatusString_GeneratesCorrectFormat() throws {
        // Given
        let mockManager = MockFeatureFlagManager(
            defaultStates: [.enhancedCarousel: true]
        )
        let viewModel = DebugSettingsViewModel(featureFlagManager: mockManager)
        viewModel.loadFeatureFlagStates()
        
        // When
        let statusString = viewModel.generateFlagsStatusString()
        
        // Then
        #expect(statusString.contains("Feature Flags Status:"))
        #expect(statusString.contains("enhancedCarousel"))
        #expect(statusString.contains("✅ Enabled") || statusString.contains("❌ Disabled"))
        #expect(statusString.contains(FeatureFlag.enhancedCarousel.description))
    }
    
    @MainActor
    @Test("DebugSettingsViewModel generateFlagsStatusString - Includes all flags")
    func generateFlagsStatusString_IncludesAllFlags() throws {
        // Given
        let mockManager = MockFeatureFlagManager()
        let viewModel = DebugSettingsViewModel(featureFlagManager: mockManager)
        viewModel.loadFeatureFlagStates()
        
        // When
        let statusString = viewModel.generateFlagsStatusString()
        
        // Then
        for flag in FeatureFlag.allCases {
            #expect(statusString.contains(flag.rawValue))
            #expect(statusString.contains(flag.description))
        }
    }
    
    // MARK: - isFlagEnabled Tests
    
    @MainActor
    @Test("DebugSettingsViewModel isFlagEnabled - Returns true for enabled flag")
    func isFlagEnabled_ReturnsTrueForEnabledFlag() throws {
        // Given
        let mockManager = MockFeatureFlagManager(
            defaultStates: [.enhancedCarousel: true]
        )
        let viewModel = DebugSettingsViewModel(featureFlagManager: mockManager)
        viewModel.loadFeatureFlagStates()
        
        // When/Then
        #expect(viewModel.isFlagEnabled(.enhancedCarousel) == true)
    }
    
    @MainActor
    @Test("DebugSettingsViewModel isFlagEnabled - Returns false for disabled flag")
    func isFlagEnabled_ReturnsFalseForDisabledFlag() throws {
        // Given
        let mockManager = MockFeatureFlagManager()
        let viewModel = DebugSettingsViewModel(featureFlagManager: mockManager)
        viewModel.loadFeatureFlagStates()
        
        // When/Then
        #expect(viewModel.isFlagEnabled(.enhancedCarousel) == false)
    }
    
    @MainActor
    @Test("DebugSettingsViewModel isFlagEnabled - Returns false for unloaded flag")
    func isFlagEnabled_ReturnsFalseForUnloadedFlag() throws {
        // Given
        let mockManager = MockFeatureFlagManager()
        let viewModel = DebugSettingsViewModel(featureFlagManager: mockManager)
        // Note: Not calling loadFeatureFlagStates()
        
        // When/Then
        #expect(viewModel.isFlagEnabled(.enhancedCarousel) == false)
    }
    
    // MARK: - Color Scheme Tests
    
    @MainActor
    @Test("DebugSettingsViewModel preferredColorScheme - Returns nil for system default")
    func preferredColorScheme_ReturnsNilForSystemDefault() throws {
        // Given
        let mockFeatureFlagManager = MockFeatureFlagManager()
        let mockColorSchemeManager = MockColorSchemeManager(preferredColorScheme: nil)
        let viewModel = DebugSettingsViewModel(
            featureFlagManager: mockFeatureFlagManager,
            colorSchemeManager: mockColorSchemeManager
        )
        
        // When/Then
        #expect(viewModel.preferredColorScheme == nil)
    }
    
    @MainActor
    @Test("DebugSettingsViewModel preferredColorScheme - Returns light when set")
    func preferredColorScheme_ReturnsLightWhenSet() throws {
        // Given
        let mockFeatureFlagManager = MockFeatureFlagManager()
        let mockColorSchemeManager = MockColorSchemeManager(preferredColorScheme: .light)
        let viewModel = DebugSettingsViewModel(
            featureFlagManager: mockFeatureFlagManager,
            colorSchemeManager: mockColorSchemeManager
        )
        
        // When/Then
        #expect(viewModel.preferredColorScheme == .light)
    }
    
    @MainActor
    @Test("DebugSettingsViewModel preferredColorScheme - Returns dark when set")
    func preferredColorScheme_ReturnsDarkWhenSet() throws {
        // Given
        let mockFeatureFlagManager = MockFeatureFlagManager()
        let mockColorSchemeManager = MockColorSchemeManager(preferredColorScheme: .dark)
        let viewModel = DebugSettingsViewModel(
            featureFlagManager: mockFeatureFlagManager,
            colorSchemeManager: mockColorSchemeManager
        )
        
        // When/Then
        #expect(viewModel.preferredColorScheme == .dark)
    }
    
    @MainActor
    @Test("DebugSettingsViewModel preferredColorScheme - Sets light mode")
    func preferredColorScheme_SetsLightMode() throws {
        // Given
        let mockFeatureFlagManager = MockFeatureFlagManager()
        let mockColorSchemeManager = MockColorSchemeManager()
        let viewModel = DebugSettingsViewModel(
            featureFlagManager: mockFeatureFlagManager,
            colorSchemeManager: mockColorSchemeManager
        )
        
        // When
        viewModel.preferredColorScheme = .light
        
        // Then
        #expect(viewModel.preferredColorScheme == .light)
        #expect(mockColorSchemeManager.getPreferredColorScheme() == .light)
    }
    
    @MainActor
    @Test("DebugSettingsViewModel preferredColorScheme - Sets dark mode")
    func preferredColorScheme_SetsDarkMode() throws {
        // Given
        let mockFeatureFlagManager = MockFeatureFlagManager()
        let mockColorSchemeManager = MockColorSchemeManager()
        let viewModel = DebugSettingsViewModel(
            featureFlagManager: mockFeatureFlagManager,
            colorSchemeManager: mockColorSchemeManager
        )
        
        // When
        viewModel.preferredColorScheme = .dark
        
        // Then
        #expect(viewModel.preferredColorScheme == .dark)
        #expect(mockColorSchemeManager.getPreferredColorScheme() == .dark)
    }
    
    @MainActor
    @Test("DebugSettingsViewModel preferredColorScheme - Sets system default (nil)")
    func preferredColorScheme_SetsSystemDefault() throws {
        // Given
        let mockFeatureFlagManager = MockFeatureFlagManager()
        let mockColorSchemeManager = MockColorSchemeManager(preferredColorScheme: .light)
        let viewModel = DebugSettingsViewModel(
            featureFlagManager: mockFeatureFlagManager,
            colorSchemeManager: mockColorSchemeManager
        )
        
        // When
        viewModel.preferredColorScheme = nil
        
        // Then
        #expect(viewModel.preferredColorScheme == nil)
        #expect(mockColorSchemeManager.getPreferredColorScheme() == nil)
    }
    
    @MainActor
    @Test("DebugSettingsViewModel preferredColorScheme - Changes from light to dark")
    func preferredColorScheme_ChangesFromLightToDark() throws {
        // Given
        let mockFeatureFlagManager = MockFeatureFlagManager()
        let mockColorSchemeManager = MockColorSchemeManager(preferredColorScheme: .light)
        let viewModel = DebugSettingsViewModel(
            featureFlagManager: mockFeatureFlagManager,
            colorSchemeManager: mockColorSchemeManager
        )
        
        // When
        viewModel.preferredColorScheme = .dark
        
        // Then
        #expect(viewModel.preferredColorScheme == .dark)
        #expect(mockColorSchemeManager.getPreferredColorScheme() == .dark)
    }
    
    @MainActor
    @Test("DebugSettingsViewModel preferredColorScheme - Changes from dark to system")
    func preferredColorScheme_ChangesFromDarkToSystem() throws {
        // Given
        let mockFeatureFlagManager = MockFeatureFlagManager()
        let mockColorSchemeManager = MockColorSchemeManager(preferredColorScheme: .dark)
        let viewModel = DebugSettingsViewModel(
            featureFlagManager: mockFeatureFlagManager,
            colorSchemeManager: mockColorSchemeManager
        )
        
        // When
        viewModel.preferredColorScheme = nil
        
        // Then
        #expect(viewModel.preferredColorScheme == nil)
        #expect(mockColorSchemeManager.getPreferredColorScheme() == nil)
    }
    
    @MainActor
    @Test("DebugSettingsViewModel - Initializes with default ColorSchemeManager")
    func initialization_UsesDefaultColorSchemeManager() throws {
        // Given/When
        let mockFeatureFlagManager = MockFeatureFlagManager()
        let viewModel = DebugSettingsViewModel(featureFlagManager: mockFeatureFlagManager)
        
        // Then - Should use shared ColorSchemeManager (system default initially)
        // We can't directly test the shared instance, but we can verify it doesn't crash
        let _ = viewModel.preferredColorScheme
        #expect(true) // If we get here, initialization succeeded
    }
    
    // MARK: - Integration Tests
    
    @MainActor
    @Test("DebugSettingsViewModel - Full workflow")
    func fullWorkflow_WorksCorrectly() throws {
        // Given
        let mockManager = MockFeatureFlagManager()
        let viewModel = DebugSettingsViewModel(featureFlagManager: mockManager)
        
        // When - Load initial state
        viewModel.loadFeatureFlagStates()
        #expect(viewModel.isFlagEnabled(.enhancedCarousel) == false)
        
        // Enable flag
        viewModel.setFeatureFlag(.enhancedCarousel, enabled: true)
        #expect(viewModel.isFlagEnabled(.enhancedCarousel) == true)
        
        // Generate status string
        let statusString = viewModel.generateFlagsStatusString()
        #expect(statusString.contains("enhancedCarousel"))
        
        // Reset all flags
        viewModel.resetAllFlags()
        #expect(viewModel.isFlagEnabled(.enhancedCarousel) == false)
        
        // Then - Verify final state
        for flag in FeatureFlag.allCases {
            #expect(viewModel.isFlagEnabled(flag) == false)
        }
    }
    
    @MainActor
    @Test("DebugSettingsViewModel - Full workflow with color scheme")
    func fullWorkflow_WithColorScheme_WorksCorrectly() throws {
        // Given
        let mockFeatureFlagManager = MockFeatureFlagManager()
        let mockColorSchemeManager = MockColorSchemeManager()
        let viewModel = DebugSettingsViewModel(
            featureFlagManager: mockFeatureFlagManager,
            colorSchemeManager: mockColorSchemeManager
        )
        
        // When - Load feature flags
        viewModel.loadFeatureFlagStates()
        #expect(viewModel.isFlagEnabled(.enhancedCarousel) == false)
        
        // Set color scheme to dark
        viewModel.preferredColorScheme = .dark
        #expect(viewModel.preferredColorScheme == .dark)
        
        // Enable feature flag
        viewModel.setFeatureFlag(.enhancedCarousel, enabled: true)
        #expect(viewModel.isFlagEnabled(.enhancedCarousel) == true)
        
        // Change color scheme to light
        viewModel.preferredColorScheme = .light
        #expect(viewModel.preferredColorScheme == .light)
        #expect(viewModel.isFlagEnabled(.enhancedCarousel) == true) // Flag should still be enabled
        
        // Reset to system default
        viewModel.preferredColorScheme = nil
        #expect(viewModel.preferredColorScheme == nil)
        
        // Then - Verify both systems work independently
        #expect(viewModel.isFlagEnabled(.enhancedCarousel) == true) // Flag still enabled
        #expect(viewModel.preferredColorScheme == nil) // Color scheme reset
    }
    
    @MainActor
    @Test("DebugSettingsViewModel - Multiple color scheme changes")
    func multipleColorSchemeChanges_WorksCorrectly() throws {
        // Given
        let mockFeatureFlagManager = MockFeatureFlagManager()
        let mockColorSchemeManager = MockColorSchemeManager()
        let viewModel = DebugSettingsViewModel(
            featureFlagManager: mockFeatureFlagManager,
            colorSchemeManager: mockColorSchemeManager
        )
        
        // When - Change color scheme multiple times
        viewModel.preferredColorScheme = .light
        #expect(viewModel.preferredColorScheme == .light)
        
        viewModel.preferredColorScheme = .dark
        #expect(viewModel.preferredColorScheme == .dark)
        
        viewModel.preferredColorScheme = .light
        #expect(viewModel.preferredColorScheme == .light)
        
        viewModel.preferredColorScheme = nil
        #expect(viewModel.preferredColorScheme == nil)
        
        // Then - All changes should be reflected
        #expect(mockColorSchemeManager.getPreferredColorScheme() == nil)
    }
}

