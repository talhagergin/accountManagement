import SwiftUI
import Charts
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddIncome = false
    @State private var showingAddExpense = false
    @State private var showingAnalytics = false
    @State private var selectedTransaction: Transaction?
    @State private var isChartExpanded = false
    @State var viewModel: TransactionViewModel
    
    private let themeColor = Color(red: 255/255, green: 182/255, blue: 193/255) // Light pink
    private let darkThemeColor = Color(red: 219/255, green: 112/255, blue: 147/255) // Darker pink
    
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
                .background(themeColor.opacity(0.3))
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
                                        ? darkThemeColor
                                        : themeColor.opacity(0.3)
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
                
                // Action Buttons
                HStack(spacing: 20) {
                    Button(action: { showingAddIncome = true }) {
                        VStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                            Text("Gelir Ekle")
                                .font(.caption)
                        }
                    }
                    
                    Button(action: { showingAddExpense = true }) {
                        VStack {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.red)
                            Text("Gider Ekle")
                                .font(.caption)
                        }
                    }
                    
                    Button(action: { showingAnalytics = true }) {
                        VStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 24))
                                .foregroundColor(darkThemeColor)
                            Text("Analiz")
                                .font(.caption)
                        }
                    }
                }
                .padding(.vertical)
                
                // Chart Section
                VStack {
                    Button(action: {
                        withAnimation {
                            isChartExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text("Grafik")
                                .font(.headline)
                            Spacer()
                            Image(systemName: isChartExpanded ? "chevron.up" : "chevron.down")
                        }
                        .padding()
                        .background(themeColor.opacity(0.3))
                        .cornerRadius(8)
                    }
                    
                    if isChartExpanded {
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
                    }
                }
                
                // Transactions List
                List {
                    ForEach(viewModel.getTransactionsForSelectedMonth()) { transaction in
                        TransactionRow(transaction: transaction)
                            .onTapGesture {
                                if transaction.isInstallment {
                                    selectedTransaction = transaction
                                }
                            }
                            .listRowBackground(themeColor.opacity(0.1))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .padding(.top)
            .navigationTitle("Hesap Yönetimi")
            .background(Color(UIColor.systemBackground))
            .sheet(isPresented: $showingAddIncome) {
                AddIncomeView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingAnalytics) {
                TransactionAnalyticsView(viewModel: viewModel)
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
                            .foregroundColor(Color(red: 219/255, green: 112/255, blue: 147/255))
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
