import SwiftUI

struct SubscriptionsView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @State private var showingAddSubscription = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Toplam tutarı gösteren kısım
                HStack {
                    Text("Total Monthly Cost:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(formattedCurrency(viewModel.getTotalMonthlyCost()))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                
                ScrollView {
                    // Aktif abonelikler listesi
                    Section(header: Text("Active Subscriptions").font(.headline).padding(.leading)) {
                        if viewModel.getActiveSubscriptions().isEmpty {
                            Text("No active subscriptions.")
                                .foregroundColor(.gray)
                                .padding(.leading)
                        } else {
                            ForEach(viewModel.getActiveSubscriptions()) { subscription in
                                SubscriptionRow(subscription: subscription, viewModel: viewModel, backgroundColor: Color(.systemGray6))
                            }
                        }
                    }
                    
                    // İptal Edilmiş Abonelikler Listesi
                    Section(header: Text("Cancelled Subscriptions").font(.headline).padding(.leading)) {
                        if viewModel.getInactiveSubscriptions().isEmpty {
                            Text("No cancelled subscriptions.")
                                .foregroundColor(.gray)
                                .padding(.leading)
                        } else {
                            ForEach(viewModel.getInactiveSubscriptions()) { subscription in
                                SubscriptionRow(subscription: subscription, viewModel: viewModel, backgroundColor: Color(.systemGray5))
                            }
                        }
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

struct SubscriptionRow: View {
    var subscription: Subscription
    @ObservedObject var viewModel: SubscriptionViewModel
    var backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(subscription.name)
                    .font(.headline)
                Spacer()
                Text(formattedCurrency(subscription.monthlyCost))
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            Text("Next Payment: \(formattedDate(subscription.nextPaymentDate))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Payment Frequency: \(subscription.paymentFrequency.rawValue)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if subscription.isActive {
                Button(action: {
                    withAnimation {
                        viewModel.cancelSubscription(subscription)
                    }
                }) {
                    Text("Cancel Subscription")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            } else {
                Text("Cancelled on: \(formattedDate(subscription.cancellationDate ?? Date()))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(10)
        .shadow(radius: 2)
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
