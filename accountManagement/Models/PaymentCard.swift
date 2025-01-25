import Foundation

struct PaymentCard: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var last4Digits: String
}
