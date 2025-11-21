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
            TabBarView()
                .preferredColorScheme(colorSchemeManager.preferredColorScheme)
                .environment(colorSchemeManager)
        }
    }
}
