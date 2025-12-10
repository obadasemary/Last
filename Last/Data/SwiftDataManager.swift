//
//  SwiftDataManager.swift
//  Last
//
//  Created by Claude Code on 04.12.2025.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataManager {
    static let shared = SwiftDataManager()

    let modelContainer: ModelContainer
    let modelContext: ModelContext

    private init() {
        do {
            let schema = Schema([
                CachedFeedEntity.self,
                CachedCharacter.self,
                CachedNewsFeedEntity.self,
                CachedEpisode.self
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to initialize SwiftData: \(error)")
        }
    }
}
