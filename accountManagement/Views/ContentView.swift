import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddIncome = false
    @State private var showingAddExpense = false
    @State private var showingAnalytics = false
    
    @State var viewModel: TransactionViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                // Balance Circle
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.3)
                        .foregroundColor(.blue)
                    
                    Circle()
                        .trim(from: 0, to: viewModel.totalBalance > 0 ? 1 : 0)
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("Toplam Para")
                            .font(.headline)
                        Text("$\(String(format: "%.2f", viewModel.totalBalance))")
                            .font(.title)
                            .bold()
                    }
                }
                .frame(height: 200)
                .padding()
                
                // Action Buttons
                HStack(spacing: 20) {
                    Button(action: { showingAddIncome = true }) {
                        VStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("Gelir Ekle")
                        }
                    }
                    
                    Button(action: { showingAddExpense = true }) {
                        VStack {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                            Text("Gider Ekle")
                        }
                    }
                    
                    Button(action: { showingAnalytics = true }) {
                        VStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.blue)
                            Text("Analiz")
                        }
                    }
                }
                .padding()
                
                // Transaction List
                List {
                    ForEach(viewModel.transactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
            }
            .navigationTitle("Hesap Yönetimi")
        }
        .sheet(isPresented: $showingAddIncome) {
            AddIncomeView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAnalytics) {
            TransactionAnalyticsView(viewModel: viewModel)
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        HStack {
            if transaction.type == .expense, let category = transaction.category {
                Image(systemName: category.icon)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(transaction.type == .income ? "Gelir" : "Gider")
                        .font(.headline)
                    if transaction.isInstallment {
                        Text("(Taksitli)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                
                if let note = transaction.note {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text(dateFormatter.string(from: transaction.date))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if transaction.isInstallment, let count = transaction.installmentCount {
                        Text("•")
                            .foregroundColor(.gray)
                        Text("\(count) Taksit")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.2f", transaction.isInstallment ? (transaction.installmentAmount ?? 0) : transaction.amount))")
                    .font(.headline)
                    .foregroundColor(transaction.type == .income ? .green : .red)
                
                if transaction.isInstallment, let paymentDate = transaction.installmentPaymentDate {
                    Text("Ödeme: \(dateFormatter.string(from: paymentDate))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
