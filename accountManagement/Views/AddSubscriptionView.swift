import Foundation
import SwiftUI

struct AddSubscriptionView: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var monthlyCost: String = ""
    @State private var startDate: Date = Date()
    @State private var nextPaymentDate: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                TextField("Subscription Name", text: $name)
                TextField("Monthly Cost", text: $monthlyCost)
                    .keyboardType(.decimalPad)
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("Next Payment Date", selection: $nextPaymentDate, displayedComponents: .date)
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
                                nextPaymentDate: nextPaymentDate
                            )
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
