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
                        Text("Total Balance")
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
                            Text("Add Income")
                        }
                    }
                    
                    Button(action: { showingAddExpense = true }) {
                        VStack {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                            Text("Add Expense")
                        }
                    }
                    
                    Button(action: { showingAnalytics = true }) {
                        VStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.blue)
                            Text("Analytics")
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
            .navigationTitle("Account Management")
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
    
    var body: some View {
        HStack {
            if transaction.type == .expense, let category = transaction.category {
                Image(systemName: category.icon)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading) {
                Text(transaction.type == .income ? "Income" : "Expense")
                    .font(.headline)
                if let note = transaction.note {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                if transaction.type == .expense, let category = transaction.category {
                    Text(category.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Text("$\(String(format: "%.2f", transaction.amount))")
                .foregroundColor(transaction.type == .income ? .green : .red)
        }
    }
}
