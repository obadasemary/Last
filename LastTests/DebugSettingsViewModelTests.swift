//
//  DebugSettingsViewModelTests.swift
//  LastTests
//
//  Unit tests for DebugSettingsViewModel
//

import Testing
import Foundation
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
}

