import Foundation

enum TransactionType: String, Codable, CaseIterable {
    case income = "Gelir"
    case expense = "Gider"
}

struct ExpenseTemplate: Identifiable, Codable {
    var id = UUID()
    var name: String
    var amount: String
    var category: TransactionCategory
    var note: String
    var type: TransactionType
}
