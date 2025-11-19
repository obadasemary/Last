//
//  ColorSchemeManager.swift
//  Last
//
//  Manages app-wide color scheme preferences
//

import SwiftUI

// MARK: - Color Scheme Manager Protocol

/// Protocol for managing color scheme preferences
protocol ColorSchemeManagerProtocol {
    /// Gets the current preferred color scheme
    /// - Returns: The preferred color scheme, or nil for system default
    func getPreferredColorScheme() -> ColorScheme?
    
    /// Sets the preferred color scheme
    /// - Parameter colorScheme: The color scheme to set, or nil for system default
    func setPreferredColorScheme(_ colorScheme: ColorScheme?)
}

// MARK: - Color Scheme Manager

/// Default implementation of color scheme management using UserDefaults
/// Observable for reactive updates across the app
@Observable
final class ColorSchemeManager: ColorSchemeManagerProtocol {
    
    /// Shared instance for app-wide color scheme management
    static let shared = ColorSchemeManager()
    
    /// UserDefaults key for storing color scheme preference
    private let userDefaultsKey = "preferredColorScheme"
    
    /// Current preferred color scheme (for reactive updates)
    /// This property is observed by SwiftUI for automatic view updates
    var preferredColorScheme: ColorScheme? {
        didSet {
            saveToUserDefaults(preferredColorScheme)
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        // Load initial value from UserDefaults
        preferredColorScheme = loadFromUserDefaults()
    }
    
    // MARK: - Color Scheme Manager Protocol
    
    func getPreferredColorScheme() -> ColorScheme? {
        return preferredColorScheme
    }
    
    func setPreferredColorScheme(_ colorScheme: ColorScheme?) {
        preferredColorScheme = colorScheme
    }
    
    // MARK: - Private Helpers
    
    private func loadFromUserDefaults() -> ColorScheme? {
        guard let rawValue = UserDefaults.standard.string(forKey: userDefaultsKey),
              let intValue = Int(rawValue) else {
            return nil // System default
        }
        
        return ColorScheme(rawValue: intValue)
    }
    
    private func saveToUserDefaults(_ colorScheme: ColorScheme?) {
        if let colorScheme = colorScheme {
            UserDefaults.standard.set(colorScheme.rawValue, forKey: userDefaultsKey)
        } else {
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        }
    }
}

// MARK: - ColorScheme Extension

extension ColorScheme {
    /// Raw value for UserDefaults storage
    var rawValue: Int {
        switch self {
        case .light:
            return 0
        case .dark:
            return 1
        @unknown default:
            return 0
        }
    }
    
    /// Creates a ColorScheme from a raw value
    init?(rawValue: Int) {
        switch rawValue {
        case 0:
            self = .light
        case 1:
            self = .dark
        default:
            return nil
        }
    }
    
    /// User-friendly display name
    var displayName: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        @unknown default:
            return "Light"
        }
    }
}

// MARK: - Mock Color Scheme Manager

/// Mock implementation for testing and previews
final class MockColorSchemeManager: ColorSchemeManagerProtocol {
    
    private var preferredColorScheme: ColorScheme?
    
    init(preferredColorScheme: ColorScheme? = nil) {
        self.preferredColorScheme = preferredColorScheme
    }
    
    func getPreferredColorScheme() -> ColorScheme? {
        return preferredColorScheme
    }
    
    func setPreferredColorScheme(_ colorScheme: ColorScheme?) {
        preferredColorScheme = colorScheme
    }
}

