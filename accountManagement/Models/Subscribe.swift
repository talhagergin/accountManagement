import Foundation

struct Subscription: Identifiable, Codable {
    var id = UUID()
    var name: String
    var monthlyCost: Double
    var startDate: Date
    var nextPaymentDate: Date
    var isActive: Bool = true
    var cancellationDate: Date?
}
