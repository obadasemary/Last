//
//  DebugSettingsView.swift
//  Last
//
//  Debug settings view for toggling feature flags and development tools
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Color Scheme Option

/// Represents color scheme selection options
enum ColorSchemeOption: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    var icon: String {
        switch self {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
    
    init?(colorScheme: ColorScheme?) {
        switch colorScheme {
        case .none:
            self = .system
        case .some(.light):
            self = .light
        case .some(.dark):
            self = .dark
        @unknown default:
            return nil
        }
    }
}

struct DebugSettingsView: View {
    
    @Bindable var viewModel: DebugSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Use @Bindable on shared manager for observation
    @Bindable private var colorSchemeManager = ColorSchemeManager.shared
    
    var body: some View {
        NavigationStack {
            Form {
                colorSchemeSection
                featureFlagsSection
                actionsSection
            }
            .navigationTitle("Debug Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadFeatureFlagStates()
            }
            .alert("Reset All Flags", isPresented: $viewModel.showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel.resetAllFlags()
                }
            } message: {
                Text("This will reset all feature flags to their default values. This action cannot be undone.")
            }
        }
        .preferredColorScheme(colorSchemeManager.preferredColorScheme)
    }
    
    // MARK: - Color Scheme Section
    
    private var colorSchemeSection: some View {
        Section {
            Picker(
                "Color Scheme",
                selection: $viewModel.colorSchemePreference
            ) {
                ForEach(ColorSchemeOption.allCases, id: \.self) { option in
                    HStack {
                        Image(systemName: option.icon)
                        Text(option.rawValue)
                    }
                    .tag(option)
                    .id(option)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: viewModel.colorSchemePreference) { oldValue, newValue in
                viewModel.handleColorSchemeChange(oldValue: oldValue, newValue: newValue)
            }
            
            // Show current selection
            HStack {
                Image(systemName: viewModel.colorSchemePreference.icon)
                    .foregroundStyle(.secondary)
                Text("Currently: \(viewModel.colorSchemePreference.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Appearance")
        } footer: {
            Text("Override the system color scheme. Set to 'System' to follow device settings.")
        }
    }
    
    // MARK: - Feature Flags Section
    
    private var featureFlagsSection: some View {
        Section {
            ForEach(FeatureFlag.allCases, id: \.self) { flag in
                FeatureFlagRow(
                    flag: flag,
                    isEnabled: Binding(
                        get: { viewModel.isFlagEnabled(flag) },
                        set: { newValue in
                            viewModel.setFeatureFlag(flag, enabled: newValue)
                        }
                    )
                )
            }
        } header: {
            Text("Feature Flags")
        } footer: {
            Text("Toggle feature flags to enable or disable experimental features. Changes take effect immediately.")
        }
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.showingResetAlert = true
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset All Flags to Defaults")
                }
            }
            
            Button {
                copyFlagsToClipboard()
            } label: {
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text("Copy Flags to Clipboard")
                }
            }
        } header: {
            Text("Actions")
        }
    }
    
    // MARK: - Helper Methods
    
    private func copyFlagsToClipboard() {
        let flagsString = viewModel.generateFlagsStatusString()
        
        #if os(iOS)
        UIPasteboard.general.string = flagsString
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(flagsString, forType: .string)
        #endif
    }
}

// MARK: - Feature Flag Row

private struct FeatureFlagRow: View {
    let flag: FeatureFlag
    @Binding var isEnabled: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $isEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(flag.rawValue)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(flag.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            if isEnabled {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption2)
                    Text("Active")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
                .padding(.leading, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    let builder = DebugSettingsBuilder()
    return builder.buildDebugSettingsView()
}

#Preview("With Enabled Flags") {
    let mockManager = MockFeatureFlagManager(
        defaultStates: [.enhancedCarousel: true]
    )
    let builder = DebugSettingsBuilder()
    return builder.buildDebugSettingsView(featureFlagManager: mockManager)
}

