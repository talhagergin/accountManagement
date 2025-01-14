import SwiftUI

struct InstallmentDetailsView: View {
    @Environment(\.dismiss) var dismiss
    let transaction: Transaction
    let viewModel: TransactionViewModel
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // Transaction Details
                Group {
                    Text("İşlem Detayları")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Toplam Tutar:")
                            Spacer()
                            Text("$\(String(format: "%.2f", transaction.amount))")
                                .foregroundColor(.red)
                        }
                        
                        HStack {
                            Text("Taksit Tutarı:")
                            Spacer()
                            Text("$\(String(format: "%.2f", transaction.installmentAmount ?? 0))")
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("Toplam Taksit:")
                            Spacer()
                            Text("\(transaction.installmentCount ?? 0)")
                        }
                        
                        HStack {
                            Text("Kalan Taksit:")
                            Spacer()
                            Text("\(transaction.remainingInstallments)")
                                .foregroundColor(transaction.remainingInstallments > 0 ? .orange : .green)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                
                // Remaining Installments
                if transaction.remainingInstallments > 0 {
                    Text("Kalan Taksitler")
                        .font(.headline)
                    
                    ForEach(0..<transaction.remainingInstallments, id: \.self) { index in
                        HStack {
                            Image(systemName: "circle")
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text("\(index + 1). Taksit")
                                    .font(.subheadline)
                                Text("$\(String(format: "%.2f", transaction.installmentAmount ?? 0))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.payInstallment(for: transaction)
                            }) {
                                Text("Öde")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                } else {
                    Text("Tüm taksitler ödenmiş!")
                        .font(.headline)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Taksit Detayları")
            .navigationBarItems(trailing: Button("Kapat") {
                dismiss()
            })
        }
    }
}
