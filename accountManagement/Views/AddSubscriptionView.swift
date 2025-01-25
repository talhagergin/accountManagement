import SwiftUI

struct AddSubscriptionView: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var monthlyCost: String = ""
    @State private var startDate: Date = Date()
    @State private var selectedFrequency: PaymentFrequency = .monthly
    
    var subscription: Subscription?
    
    var isEditing: Bool {
        subscription != nil
    }
    
    init(viewModel: SubscriptionViewModel, subscription: Subscription? = nil) {
            self.viewModel = viewModel
            self.subscription = subscription
            
            if let subscription = subscription {
                _name = State(initialValue: subscription.name)
                _monthlyCost = State(initialValue: String(subscription.monthlyCost))
                _startDate = State(initialValue: subscription.startDate)
                _selectedFrequency = State(initialValue: subscription.paymentFrequency)
            }
        }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Subscription Details")) {
                    TextField("Subscription Name", text: $name)
                    TextField("Monthly Cost", text: $monthlyCost)
                        .keyboardType(.decimalPad)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    Picker("Payment Frequency", selection: $selectedFrequency) {
                        ForEach(PaymentFrequency.allCases) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Subscription" : "Add Subscription")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Update" : "Save") {
                        if let cost = Double(monthlyCost) {
                            if isEditing, let subscription = subscription {
                                 viewModel.updateSubscription(
                                    subscription: subscription,
                                    name: name,
                                    monthlyCost: cost,
                                    startDate: startDate,
                                    paymentFrequency: selectedFrequency
                                 )
                             } else {
                                    viewModel.addSubscription(
                                    name: name,
                                    monthlyCost: cost,
                                    startDate: startDate,
                                    paymentFrequency: selectedFrequency
                                    )
                                }
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
