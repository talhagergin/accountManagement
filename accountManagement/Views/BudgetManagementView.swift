import SwiftUI

struct BudgetManagementView: View {
    @ObservedObject var viewModel: TransactionViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.budgets) { budget in
                    BudgetCard(budget: budget)
                }
            }
            .navigationTitle("Bütçe Yönetimi")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { /* Add new budget action */ }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct BudgetCard: View {
    let budget: Budget
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(budget.category.rawValue)
                    .font(.headline)
                Spacer()
                Text("₺\(String(format: "%.2f", budget.remainingAmount)) / ₺\(String(format: "%.2f", budget.amount))")
                    .font(.subheadline)
            }
            
            ProgressView(value: budget.spentAmount, total: budget.amount)
                .accentColor(budget.isOverBudget ? .red : .green)
            
            if budget.isOverBudget {
                Text("Bütçe Aşıldı!")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
