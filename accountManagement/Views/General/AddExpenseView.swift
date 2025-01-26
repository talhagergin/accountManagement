// View/AddExpenseView.swift
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
    
    @AppStorage("expenseTemplates") private var expenseTemplatesData: Data = Data()
    @State private var expenseTemplates: [ExpenseTemplate] = []
    @State private var showingTemplateManagement = false
    

    private var isValidAmount: Bool {
        guard let amountDouble = Double(amount) else { return false }
        return amountDouble > 0
    }
    
    private var isValidInstallment: Bool {
        if !isInstallment { return true }
        guard let count = Int(installmentCount) else { return false }
        return count > 0
    }
    
    
    func loadTemplates(){
        if let decoded = try? JSONDecoder().decode([ExpenseTemplate].self, from: expenseTemplatesData) {
            expenseTemplates = decoded
        }
        
    }
    
    func saveTemplates(){
        if let encoded = try? JSONEncoder().encode(expenseTemplates) {
            expenseTemplatesData = encoded
        }
        
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        DatePicker("Tarih", selection: $selectedDate, displayedComponents: .date)
                    }
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(.gray)
                        TextField("Miktar", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                   
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.gray)
                        Picker("Kategori", selection: $category) {
                            ForEach(TransactionCategory.allCases, id: \.self) { category in
                                Label(category.rawValue, systemImage: category.icon)
                                    .tag(category)
                            }
                        }
                    }

                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.gray)
                        TextField("Açıklama", text: $note)
                        
                    }
                    
                    HStack {
                        Image(systemName: "calendar.badge.minus")
                            .foregroundColor(.gray)
                        Toggle("Taksitli", isOn: $isInstallment)
                    }
                    
                    
                    if isInstallment {
                        HStack {
                            Image(systemName: "number.square.fill")
                                .foregroundColor(.gray)
                            TextField("Taksit Sayısı", text: $installmentCount)
                                .keyboardType(.numberPad)
                        }

                        HStack{
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(.gray)
                            DatePicker("Taksit Ödeme Tarihi", selection: $installmentPaymentDate, displayedComponents: .date)
                        }
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
                
                Section(header: Text("Şablonlar")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(expenseTemplates.filter { $0.type == .expense }) { template in
                                Button(action: {
                                    amount = template.amount
                                    category = template.category
                                    note = template.note
                                }) {
                                    VStack {
                                        Text(template.name)
                                            .font(.caption)
                                        Text(template.amount)
                                            .font(.caption)
                                            .bold()
                                            .foregroundColor(.blue)
                                        
                                        Label(template.category.rawValue, systemImage: template.category.icon)
                                            .font(.caption)
                                        
                                    }
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    Button("Şablonları Yönet") {
                        showingTemplateManagement = true
                    }
                }
            }
            .onAppear(perform: {
                loadTemplates()
            })
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
            .sheet(isPresented: $showingTemplateManagement) {
                TemplateManagementView(templates: $expenseTemplates, saveAction: saveTemplates )
            }
        }
    }
}
