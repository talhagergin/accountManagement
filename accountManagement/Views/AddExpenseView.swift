import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    var viewModel: TransactionViewModel
    
    @State private var amount: String = ""
    @State private var category: TransactionCategory = .other
    @State private var note: String = ""
    @State private var isInstallment: Bool = false
    @State private var installmentCount: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Miktar", text: $amount)
                    .keyboardType(.decimalPad)
                
                Picker("Kategori", selection: $category) {
                    ForEach(TransactionCategory.allCases, id: \.self) { category in
                        Label(category.rawValue, systemImage: category.icon)
                            .tag(category)
                    }
                }
                
                TextField("Açıklama", text: $note)
                
                Toggle("Taksitli", isOn: $isInstallment)
                
                if isInstallment {
                    TextField("Taksit Sayısı", text: $installmentCount)
                        .keyboardType(.numberPad)
                }
                
                if isInstallment && !installmentCount.isEmpty {
                    if let amountDouble = Double(amount), let count = Int(installmentCount) {
                        VStack(alignment: .leading) {
                            Text("Aylık Taksit Miktarı:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("$\(String(format: "%.2f", amountDouble / Double(count)))")
                                .font(.headline)
                        }
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Add") {
                    if let amountDouble = Double(amount) {
                        viewModel.addTransaction(
                            amount: amountDouble,
                            type: .expense,
                            category: category,
                            note: note.isEmpty ? nil : note,
                            installmentCount: isInstallment ? Int(installmentCount) : nil
                        )
                        dismiss()
                    }
                }
            )
        }
    }
}
