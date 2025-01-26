// View/AddIncomeView.swift
import SwiftUI

struct AddIncomeView: View {
    @Environment(\.dismiss) var dismiss
    var viewModel: TransactionViewModel
    
    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var selectedDate: Date = Date()
    
    @AppStorage("expenseTemplates") private var expenseTemplatesData: Data = Data()
    @State private var expenseTemplates: [ExpenseTemplate] = []
    @State private var showingTemplateManagement = false
    
    private var isValidAmount: Bool {
        guard let amountDouble = Double(amount) else { return false }
        return amountDouble > 0
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
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.gray)
                         TextField("Açıklama", text: $note)
                    }
                    
                }
                
                Section(header: Text("Şablonlar")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(expenseTemplates.filter { $0.type == .income }) { template in
                                Button(action: {
                                    amount = template.amount
                                    note = template.note
                                }) {
                                    VStack {
                                        Text(template.name)
                                            .font(.caption)
                                        Text(template.amount)
                                            .font(.caption)
                                            .bold()
                                            .foregroundColor(.blue)
                                        
                                        Label(template.type.rawValue, systemImage: template.type == .income ? "arrow.up.square.fill" : "arrow.down.square.fill")
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
            .sheet(isPresented: $showingTemplateManagement) {
                TemplateManagementView(templates: $expenseTemplates, saveAction: saveTemplates )
            }
        }
    }
}
