import Foundation
import SwiftData

@Model
final class Budget: Identifiable {
    var id = UUID()
    var amount: Double
    var category: TransactionCategory
    var startDate: Date
    var endDate: Date
    var spentAmount: Double
    
    var remainingAmount: Double {
        amount - spentAmount
    }
    
    var isOverBudget: Bool {
        spentAmount > amount
    }
    
    init(amount: Double, category: TransactionCategory, startDate: Date, endDate: Date) {
        self.amount = amount
        self.category = category
        self.startDate = startDate
        self.endDate = endDate
        self.spentAmount = 0.0
    }
}
