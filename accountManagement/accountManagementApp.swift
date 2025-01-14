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
        do {
            container = try ModelContainer(for: Transaction.self)
        } catch {
            fatalError("Failed to initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: TransactionViewModel(modelContext: container.mainContext))
        }
        .modelContainer(container)
    }
}
