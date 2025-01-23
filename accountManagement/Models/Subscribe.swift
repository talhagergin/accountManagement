import Foundation

enum PaymentFrequency: String, Codable, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "3-Months"

    var id: String { self.rawValue }
}

struct Subscription: Identifiable, Codable {
    var id = UUID()
    var name: String
    var monthlyCost: Double
    var startDate: Date
    var nextPaymentDate: Date
    var paymentFrequency: PaymentFrequency
    var isActive: Bool = true
    var cancellationDate: Date?
}
