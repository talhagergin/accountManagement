import Foundation
import SwiftUI

class DebtViewModel: ObservableObject {
    @Published var debts: [Debt] = []
    
    private let userDefaults = UserDefaults.standard
    private let debtsKey = "savedDebts"
    
    init() {
        loadDebts()
    }
    
    func addDebt(personId: UUID, amount: Double, date: Date) {
        let newDebt = Debt(personId: personId, amount: amount, date: date)
        debts.append(newDebt)
        saveDebts()
    }
    
    func markAsPaid(_ debt: Debt) {
        if let index = debts.firstIndex(where: { $0.id == debt.id }) {
            var updatedDebt = debt
            updatedDebt.isPaid = true
            updatedDebt.paidDate = Date()
            debts[index] = updatedDebt
            saveDebts()
        }
    }
    
    func getActiveDebts() -> [Debt] {
        return debts.filter { !$0.isPaid }
    }
    
    func getPaidDebts() -> [Debt] {
        return debts.filter { $0.isPaid }
    }
    
    func getDebtsForPerson(personId: UUID) -> [Debt] {
        return debts.filter { $0.personId == personId }
    }
    
    func getActiveDebtsForPerson(personId: UUID) -> [Debt] {
        return debts.filter { $0.personId == personId && !$0.isPaid }
    }
    
    func getTotalDebtForPerson(personId: UUID) -> Double {
        return getActiveDebtsForPerson(personId: personId)
            .reduce(0) { $0 + $1.amount }
    }
    
    private func saveDebts() {
        if let encoded = try? JSONEncoder().encode(debts) {
            userDefaults.set(encoded, forKey: debtsKey)
        }
    }
    
    private func loadDebts() {
        if let data = userDefaults.data(forKey: debtsKey),
           let decoded = try? JSONDecoder().decode([Debt].self, from: data) {
            debts = decoded
        }
    }
}
