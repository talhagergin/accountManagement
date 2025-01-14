import SwiftUI
import Charts
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddIncome = false
    @State private var showingAddExpense = false
    @State private var selectedTransaction: Transaction?
    @State var viewModel: TransactionViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Balance Card
                VStack {
                    Text("Toplam Bakiye")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("$\(String(format: "%.2f", viewModel.totalBalance))")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(viewModel.totalBalance >= 0 ? .green : .red)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Month Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.getAvailableMonths(), id: \.self) { month in
                            Button(action: {
                                viewModel.selectMonth(month)
                            }) {
                                Text(viewModel.monthString(for: month))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Calendar.current.isDate(month, equalTo: viewModel.selectedMonth, toGranularity: .month)
                                        ? Color.blue
                                        : Color.gray.opacity(0.2)
                                    )
                                    .foregroundColor(
                                        Calendar.current.isDate(month, equalTo: viewModel.selectedMonth, toGranularity: .month)
                                        ? .white
                                        : .primary
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Chart
                let monthTransactions = viewModel.getTransactionsForSelectedMonth()
                if !monthTransactions.isEmpty {
                    Chart {
                        ForEach(monthTransactions) { transaction in
                            BarMark(
                                x: .value("Date", transaction.date, unit: .day),
                                y: .value("Amount", transaction.type == .income ? transaction.amount : -transaction.amount)
                            )
                            .foregroundStyle(transaction.type == .income ? Color.green : Color.red)
                        }
                    }
                    .frame(height: 200)
                    .padding()
                } else {
                    Text("Bu ay için işlem bulunmamaktadır")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                // Transactions List
                List {
                    ForEach(monthTransactions) { transaction in
                        TransactionRow(transaction: transaction)
                            .onTapGesture {
                                if transaction.isInstallment {
                                    selectedTransaction = transaction
                                }
                            }
                    }
                }
            }
            .padding(.top)
            .navigationTitle("Hesap Yönetimi")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingAddIncome = true }) {
                            Label("Gelir Ekle", systemImage: "plus.circle.fill")
                        }
                        Button(action: { showingAddExpense = true }) {
                            Label("Gider Ekle", systemImage: "minus.circle.fill")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddIncome) {
                AddIncomeView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(viewModel: viewModel)
            }
            .sheet(item: $selectedTransaction) { transaction in
                InstallmentDetailsView(transaction: transaction, viewModel: viewModel)
            }
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    if let category = transaction.category {
                        Image(systemName: category.icon)
                            .foregroundColor(.blue)
                    }
                    
                    if transaction.isInstallment {
                        Text("\(transaction.remainingInstallments)/\(transaction.installmentCount ?? 0) Taksit")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
                
                if let note = transaction.note {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("$\(String(format: "%.2f", transaction.isInstallment ? (transaction.installmentAmount ?? 0) : transaction.amount))")
                    .foregroundColor(transaction.type == .income ? .green : .red)
                    .font(.headline)
            }
        }
        .padding(.vertical, 4)
    }
}
