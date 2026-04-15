//
//  SwiftExampleProjectApp.swift
//  SwiftExampleProject
//
//  Created by Gabriel Mc Gann on 13/04/2026.
//

import SwiftUI
import SwiftData

@main
struct SwiftExampleProjectApp: App {
    private let modelContainer: ModelContainer
    private let dependencies: AppDependencyContainer

    init() {
        let schema = Schema([
            Item.self,
            CustomerRecord.self,
            PaymentTransactionRecord.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.modelContainer = container
            self.dependencies = AppDependencyContainer(modelContext: container.mainContext)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: dependencies)
        }
        .modelContainer(modelContainer)
    }
}
