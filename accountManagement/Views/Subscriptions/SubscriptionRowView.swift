import SwiftUI

struct SubscriptionRowView: View {
    var subscription: Subscription
   @ObservedObject var viewModel: SubscriptionViewModel
    var backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(subscription.name)
                    .font(.headline)
                Spacer()
                Text(formattedCurrency(subscription.monthlyCost))
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            Text("Sonraki Ödeme Tarihi: \(formattedDate(subscription.nextPaymentDate))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Ödeme Sıklığı: \(subscription.paymentFrequency.rawValue)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            if let paymentCard = subscription.paymentCard {
                Text("Ödeme Kartı: \(paymentCard.name) - \(paymentCard.last4Digits)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private func formattedCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
