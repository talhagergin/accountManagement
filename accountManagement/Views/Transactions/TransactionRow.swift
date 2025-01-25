import SwiftUI

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
