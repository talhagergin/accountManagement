import SwiftUI

struct AddDebtView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var debtViewModel: DebtViewModel
    @ObservedObject var personViewModel: PersonViewModel
    
    @State private var selectedPerson: Person?
    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var showingAddPerson = false
    @State private var newPersonName: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Borç Detayları")) {
                    HStack {
                        Picker("Kişi", selection: $selectedPerson) {
                            Text("Kişi Seçin").tag(nil as Person?)
                            ForEach(personViewModel.people, id: \.self) { person in
                                Text(person.name).tag(person as Person?)
                            }
                        }
                        
                        Button(action: { showingAddPerson = true }) {
                            Image(systemName: "person.badge.plus")
                        }
                    }
                    
                    TextField("Miktar", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Tarih", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Borç Ekle")
            .navigationBarItems(
                leading: Button("İptal") {
                    dismiss()
                },
                trailing: Button("Kaydet") {
                    if let person = selectedPerson,
                       let amountDouble = Double(amount) {
                        debtViewModel.addDebt(personId: person.id, amount: amountDouble, date: date)
                        dismiss()
                    }
                }
                .disabled(selectedPerson == nil || amount.isEmpty)
            )
            .sheet(isPresented: $showingAddPerson) {
                NavigationView {
                    Form {
                        TextField("Kişi Adı", text: $newPersonName)
                    }
                    .navigationTitle("Yeni Kişi Ekle")
                    .navigationBarItems(
                        leading: Button("İptal") {
                            showingAddPerson = false
                        },
                        trailing: Button("Ekle") {
                            if !newPersonName.isEmpty {
                                personViewModel.addPerson(name: newPersonName)
                                showingAddPerson = false
                                newPersonName = ""
                            }
                        }
                    )
                }
            }
        }
    }
}
