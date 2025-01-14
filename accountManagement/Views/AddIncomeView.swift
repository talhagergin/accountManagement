import SwiftUI

struct AddIncomeView: View {
    @Environment(\.dismiss) var dismiss
    var viewModel: TransactionViewModel
    
    @State private var amount: String = ""
    @State private var note: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Miktar", text: $amount)
                    .keyboardType(.decimalPad)
                
                TextField("Açıklama", text: $note)
            }
            .navigationTitle("Gelir Ekle")
            .navigationBarItems(
                leading: Button("İptal") {
                    dismiss()
                },
                trailing: Button("Ekle") {
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
