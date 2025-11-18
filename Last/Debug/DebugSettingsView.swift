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

struct DebugSettingsView: View {
    
    @State var viewModel: DebugSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
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

