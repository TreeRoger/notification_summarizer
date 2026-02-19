//
//  NotificationSummarizerApp.swift
//  NotificationSummarizer
//
//  Multiplatform app entry point.
//

import SwiftUI
import SwiftData

@main
struct NotificationSummarizerApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([NotificationItem.self])
        let config = ModelConfiguration(
            isStoredInMemoryOnly: false,
            groupContainer: .automatic
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
