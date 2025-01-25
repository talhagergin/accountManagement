// View/SubscriptionsView.swift

import SwiftUI

struct SubscriptionsView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @State private var showingAddSubscription = false
    @State private var selectedSubscriptionForEdit: Subscription?
    @State private var showingDeleteAlert = false
    @State private var subscriptionToDelete: Subscription?
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Toplam Ücret:")
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
                
                List {
                    Section(header: Text("Aktif Abonelikler").font(.headline).padding(.leading)) {
                        if viewModel.getActiveSubscriptions().isEmpty {
                            Text("Aktif aboneliğiniz bulunmamaktadır.")
                                .foregroundColor(.gray)
                                .padding(.leading)
                        } else {
                            ForEach(viewModel.getActiveSubscriptions()) { subscription in
                                SubscriptionRowView(subscription: subscription, viewModel: viewModel, backgroundColor: Color(.systemGray6))
                                    .onTapGesture {
                                        selectedSubscriptionForEdit = subscription
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            viewModel.cancelSubscription(subscription)
                                        } label: {
                                            Label("İptal Et", systemImage: "xmark.circle")
                                        }
                                    }
                                    
                            }
                        }
                    }
                    
                    Section(header: Text("İptal Edilen Abonelikler").font(.headline).padding(.leading)) {
                        if viewModel.getInactiveSubscriptions().isEmpty {
                            Text("İptal edilen aboneliğiniz bulunmamaktadır.")
                                .foregroundColor(.gray)
                                .padding(.leading)
                        } else {
                            ForEach(viewModel.getInactiveSubscriptions()) { subscription in
                                SubscriptionRowView(subscription: subscription, viewModel: viewModel, backgroundColor: Color(.systemGray5))
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            subscriptionToDelete = subscription
                                            showingDeleteAlert = true
                                        } label: {
                                            Label("Sil", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        Button {
                                            viewModel.reactivateSubscription(subscription)
                                        } label: {
                                            Label("Aktif Et", systemImage: "arrow.clockwise")
                                        }
                                    }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Abonelikler")
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
            .sheet(item: $selectedSubscriptionForEdit) { subscription in
                AddSubscriptionView(viewModel: viewModel, subscription: subscription)
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Aboneliği sil"),
                    message: Text("Aboneliğinizi silmek istediğinize emin misiniz?"),
                    primaryButton: .destructive(Text("Sil")) {
                        if let subscription = subscriptionToDelete {
                            viewModel.deleteSubscription(subscription)
                        }
                        subscriptionToDelete = nil
                    },
                    secondaryButton: .cancel()
                )
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
