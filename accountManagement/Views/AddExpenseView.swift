import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    var viewModel: TransactionViewModel
    
    @State private var amount: String = ""
    @State private var category: TransactionCategory = .other
    @State private var note: String = ""
    @State private var isInstallment: Bool = false
    @State private var installmentCount: String = ""
    @State private var selectedDate: Date = Date()
    @State private var installmentPaymentDate: Date = Date()
    
    private var isValidAmount: Bool {
        guard let amountDouble = Double(amount) else { return false }
        return amountDouble > 0
    }
    
    private var isValidInstallment: Bool {
        if !isInstallment { return true }
        guard let count = Int(installmentCount) else { return false }
        return count > 0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Miktar", text: $amount)
                    .keyboardType(.decimalPad)
                
                //DatePicker("Tarih", selection: $selectedDate, displayedComponents: .date)
                
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
                    
                    DatePicker("Taksit Ödeme Tarihi", selection: $installmentPaymentDate, displayedComponents: .date)
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
            .navigationTitle("Gider Ekle")
            .navigationBarItems(
                leading: Button("İptal") {
                    dismiss()
                },
                trailing: Button("Ekle") {
                    if let amountDouble = Double(amount), amountDouble > 0 {
                        viewModel.addTransaction(
                            amount: amountDouble,
                            date: selectedDate,
                            type: .expense,
                            category: category,
                            note: note.isEmpty ? nil : note,
                            installmentCount: isInstallment ? Int(installmentCount) : nil,
                            installmentPaymentDate: isInstallment ? installmentPaymentDate : nil
                        )
                        dismiss()
                    }
                }
                .disabled(!isValidAmount || !isValidInstallment)
            )
        }
    }
}
