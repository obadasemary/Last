//
//  LastApp.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 02.11.2025.
//

import SwiftUI

@main
struct LastApp: App {
    
    @State private var colorSchemeManager = ColorSchemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(colorSchemeManager)
        }
    }
}

// MARK: - Content View

/// Root content view that applies color scheme preference
private struct ContentView: View {
    @Environment(ColorSchemeManager.self) private var colorSchemeManager
    
    var body: some View {
        TabBarView()
            .preferredColorScheme(colorSchemeManager.getPreferredColorScheme())
    }
}
