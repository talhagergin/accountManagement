import SwiftUI

struct AddIncomeView: View {
    @Environment(\.dismiss) var dismiss
    var viewModel: TransactionViewModel
    
    @State private var amount: String = ""
    @State private var note: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                
                TextField("Note", text: $note)
            }
            .navigationTitle("Add Income")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Add") {
                    if let amountDouble = Double(amount) {
                        viewModel.addTransaction(
                            amount: amountDouble,
                            type: .income,
                            note: note.isEmpty ? nil : note
                        )
                        dismiss()
                    }
                }
            )
        }
    }
}
