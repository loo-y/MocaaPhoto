//
//  MocaaPhotoApp.swift
//  MocaaPhoto
//
//  Created by Loo on 2024/2/19.
//

import SwiftUI
import SwiftData


@main
struct MocaaPhotoApp: App {
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
            MocaaAddView()
        }
        .modelContainer(sharedModelContainer)
    }
}
