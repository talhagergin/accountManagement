//
//  AccountManagementApp.swift
//  accountManagement
//
//  Created by Talha Gergin on 15.01.2025.
//

import SwiftUI
import SwiftData

@main
struct AccountManagementApp: App {
    let container: ModelContainer
    
    init() {
        let schema = Schema([
            Transaction.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: TransactionViewModel(modelContext: container.mainContext))
        }
        .modelContainer(container)
    }
}
