//
//  SubscriptionsView.swift
//  accountManagement
//
//  Created by Talha Gergin on 23.01.2025.
//

import SwiftUI

struct SubscriptionsView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @State private var showingAddSubscription = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Active Subscriptions")) {
                    ForEach(viewModel.getActiveSubscriptions()) { subscription in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(subscription.name)
                                    .font(.headline)
                                Text("Next Payment: \(formattedDate(subscription.nextPaymentDate))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("₺\(subscription.monthlyCost, specifier: "%.2f")")
                                .font(.headline)
                        }
                    }
                }
                
                Section(header: Text("Cancelled Subscriptions")) {
                    ForEach(viewModel.getInactiveSubscriptions()) { subscription in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(subscription.name)
                                    .font(.headline)
                                if let cancellationDate = subscription.cancellationDate {
                                    Text("Cancelled: \(formattedDate(cancellationDate))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Text("₺\(subscription.monthlyCost, specifier: "%.2f")")
                                .font(.headline)
                                .strikethrough()
                        }
                    }
                }
            }
            .navigationTitle("Subscriptions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSubscription.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSubscription) {
                AddSubscriptionView(viewModel: viewModel)
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
