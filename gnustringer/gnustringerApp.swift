//
//  gnustringerApp.swift
//  gnustringer
//
//  Created by Benedikt Gottstein on 20.05.2025.
//

import SwiftUI
import SwiftData

@main
struct gnustringerApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            RecentFile.self,
            RecentDirectory.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .modelContainer(sharedModelContainer)
        } label: {
            Image(systemName: "hat.cap.fill")
//            Image("menuIcon")

        }
        .menuBarExtraStyle(.window)
    }
}
