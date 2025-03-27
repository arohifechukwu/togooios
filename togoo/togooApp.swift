//
//  togooApp.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-02.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct togooApp: App {
    // Configure Firebase in the initializer
    init() {
        FirebaseApp.configure()
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            SplashScreen() // Replace ContentView with SplashScreen
        }
        .modelContainer(sharedModelContainer)
    }
}


