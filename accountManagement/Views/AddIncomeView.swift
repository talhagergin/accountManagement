import SwiftUI

struct AddIncomeView: View {
    @Environment(\.dismiss) var dismiss
    var viewModel: TransactionViewModel
    
    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var selectedDate: Date = Date()
    
    private var isValidAmount: Bool {
        guard let amountDouble = Double(amount) else { return false }
        return amountDouble > 0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Miktar", text: $amount)
                    .keyboardType(.decimalPad)
                
                DatePicker("Tarih", selection: $selectedDate, displayedComponents: .date)
                
                TextField("Açıklama", text: $note)
            }
            .navigationTitle("Gelir Ekle")
            .navigationBarItems(
                leading: Button("İptal") {
                    dismiss()
                },
                trailing: Button("Ekle") {
                    if let amountDouble = Double(amount), amountDouble > 0 {
                        viewModel.addTransaction(
                            amount: amountDouble,
                            date: selectedDate,
                            type: .income,
                            note: note.isEmpty ? nil : note
                        )
                        dismiss()
                    }
                }
                .disabled(!isValidAmount)
            )
        }
    }
}
