import Foundation

struct Debt: Identifiable, Codable {
    var id = UUID()
    var personId: UUID
    var amount: Double
    var date: Date
    var isPaid: Bool = false
    var paidDate: Date?
}
