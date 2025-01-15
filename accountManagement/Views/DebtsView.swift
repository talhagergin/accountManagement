import SwiftUI

struct DebtsView: View {
    @StateObject private var debtViewModel = DebtViewModel()
    @StateObject private var personViewModel = PersonViewModel()
    @State private var showingAddDebt = false
    @State private var selectedPerson: Person?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(personViewModel.people) { person in
                    let totalDebt = debtViewModel.getTotalDebtForPerson(personId: person.id)
                    if totalDebt > 0 {
                        NavigationLink(destination: PersonDebtsView(person: person, debtViewModel: debtViewModel, personViewModel: personViewModel)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(person.name)
                                        .font(.headline)
                                    Text("Toplam Borç: \(totalDebt, specifier: "%.2f") TL")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Borçlar")
            .navigationBarItems(trailing: Button(action: {
                showingAddDebt = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddDebt) {
                AddDebtView(debtViewModel: debtViewModel, personViewModel: personViewModel)
            }
        }
    }
}

struct PersonDebtsView: View {
    let person: Person
    @ObservedObject var debtViewModel: DebtViewModel
    @ObservedObject var personViewModel: PersonViewModel
    @State private var showingAddDebt = false
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            // Toplam borç gösterimi
            VStack {
                Text("Toplam Borç")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("\(debtViewModel.getTotalDebtForPerson(personId: person.id), specifier: "%.2f") TL")
                    .font(.title)
                    .foregroundColor(.red)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
            .padding()
            
            Picker("", selection: $selectedTab) {
                Text("Aktif Borçlar").tag(0)
                Text("Ödenmiş Borçlar").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            if selectedTab == 0 {
                ActiveDebtsList(person: person, debtViewModel: debtViewModel)
            } else {
                PaidDebtsList(person: person, debtViewModel: debtViewModel)
            }
        }
        .navigationTitle(person.name)
        .navigationBarItems(trailing: Button(action: {
            showingAddDebt = true
        }) {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $showingAddDebt) {
            AddDebtView(debtViewModel: debtViewModel, personViewModel: personViewModel)
        }
    }
}

struct ActiveDebtsList: View {
    let person: Person
    @ObservedObject var debtViewModel: DebtViewModel
    
    var body: some View {
        List {
            ForEach(debtViewModel.getActiveDebtsForPerson(personId: person.id)) { debt in
                DebtRow(debt: debt) {
                    debtViewModel.markAsPaid(debt)
                }
            }
        }
    }
}

struct PaidDebtsList: View {
    let person: Person
    @ObservedObject var debtViewModel: DebtViewModel
    
    var body: some View {
        List {
            ForEach(debtViewModel.getDebtsForPerson(personId: person.id).filter { $0.isPaid }) { debt in
                VStack(alignment: .leading) {
                    Text("\(debt.amount, specifier: "%.2f") TL")
                        .font(.headline)
                    HStack {
                        Text("Borç Tarihi: \(debt.date.formatted(date: .abbreviated, time: .omitted))")
                        Spacer()
                        if let paidDate = debt.paidDate {
                            Text("Ödeme: \(paidDate.formatted(date: .abbreviated, time: .omitted))")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

struct DebtRow: View {
    let debt: Debt
    let onMarkAsPaid: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(debt.amount, specifier: "%.2f") TL")
                .font(.headline)
            Text("Tarih: \(debt.date.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button(action: onMarkAsPaid) {
                Text("Ödendi Olarak İşaretle")
                    .foregroundColor(.green)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }
}
