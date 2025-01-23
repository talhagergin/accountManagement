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
            VStack {
                // Toplam tutarı gösteren kısım
                Text("Total Monthly Cost: \(formattedCurrency(viewModel.getTotalMonthlyCost()))")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                // Abonelik listesi
                List {
                    ForEach(viewModel.getActiveSubscriptions()) { subscription in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(subscription.name)
                                    .font(.headline)
                                Spacer()
                                Text(formattedCurrency(subscription.monthlyCost))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Text("Next Payment: \(formattedDate(subscription.nextPaymentDate))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Payment Frequency: \(subscription.paymentFrequency.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            // Abonelik iptal butonu
                            Button(action: {
                                withAnimation {
                                    viewModel.cancelSubscription(subscription)
                                }
                            }) {
                                Text("Cancel Subscription")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }
                }
                .listStyle(PlainListStyle())
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
    
    private func formattedCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

