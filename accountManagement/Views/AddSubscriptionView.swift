import SwiftUI

struct AddSubscriptionView: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var monthlyCost: String = ""
    @State private var startDate: Date = Date()
    @State private var selectedFrequency: PaymentFrequency = .monthly

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
            .navigationTitle("Add Subscription")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let cost = Double(monthlyCost) {
                            viewModel.addSubscription(
                                name: name,
                                monthlyCost: cost,
                                startDate: startDate,
                                paymentFrequency: selectedFrequency
                            )
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
