import Foundation
import SwiftData

@Model
class Transaction {
    var amount: Double
    var date: Date
    var type: TransactionType
    var category: TransactionCategory?
    var note: String?
    var installmentCount: Int?
    var installmentAmount: Double?
    var isInstallment: Bool
    var installmentPaymentDate: Date?
    var paidInstallments: Int? = 0
    
    init(amount: Double, date: Date = Date(), type: TransactionType, category: TransactionCategory? = nil, note: String? = nil, installmentCount: Int? = nil, installmentPaymentDate: Date? = nil) {
        self.amount = amount
        self.date = date
        self.type = type
        self.category = category
        self.note = note
        self.isInstallment = installmentCount != nil
        self.installmentCount = installmentCount
        self.installmentPaymentDate = installmentPaymentDate
        self.paidInstallments = 0
        if let count = installmentCount {
            self.installmentAmount = amount / Double(count)
        } else {
            self.installmentAmount = nil
        }
    }
    
    convenience init() {
        self.init(amount: 0, type: .expense)
    }
    
    var remainingInstallments: Int {
        guard let total = installmentCount, let paid = paidInstallments else { return 0 }
        return total - paid
    }
}

enum TransactionType: String, Codable {
    case income = "Gelir"
    case expense = "Gider"
}

enum TransactionCategory: String, Codable, CaseIterable {
    case food = "Yiyecek"
    case clothing = "Giyim"
    case transportation = "Ulaşım"
    case entertainment = "Eğlence"
    case utilities = "Faturalar"
    case healthcare = "Sağlık"
    case education = "Eğitim"
    case shopping = "Alışveriş"
    case other = "Diğer"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .clothing: return "tshirt"
        case .transportation: return "car"
        case .entertainment: return "tv"
        case .utilities: return "bolt"
        case .healthcare: return "cross.case"
        case .education: return "book"
        case .shopping: return "cart"
        case .other: return "square.grid.2x2"
        }
    }
}
