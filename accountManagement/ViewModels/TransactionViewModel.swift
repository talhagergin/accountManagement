import Foundation
import SwiftData
import UserNotifications

@Observable
class TransactionViewModel: ObservableObject {
    private let modelContext: ModelContext
    var transactions: [Transaction] = []
    var selectedMonth: Date = Date()
    private var _totalBalance: Double = 0 // Stored property for the total balance

    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    var totalBalance: Double {
        let monthTransactions = getTransactionsForSelectedMonth()
        return monthTransactions.reduce(0) { total, transaction in
            let amount = transaction.isInstallment ? (transaction.installmentAmount ?? 0) : transaction.amount
            return total + (transaction.type == .income ? amount : -amount)
        }
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchTransactions()
        setupNotifications()
    }

    // MARK: - Month-based Functions

    func getAvailableMonths() -> [Date] {
        let calendar = Calendar.current
        let sortedTransactions = transactions.sorted { $0.date > $1.date }

        var months: Set<Date> = []

        for transaction in sortedTransactions {
            if let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: transaction.date)) {
                months.insert(startOfMonth)
            }
        }

        // Eğer hiç işlem yoksa, en azından mevcut ayı göster
        if months.isEmpty {
            if let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) {
                months.insert(currentMonth)
            }
        }

        return Array(months).sorted(by: >)
    }

    func getTransactionsForSelectedMonth() -> [Transaction] {
        let calendar = Calendar.current
        return transactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: selectedMonth, toGranularity: .month)
        }
    }

    func monthString(for date: Date) -> String {
        monthFormatter.string(from: date)
    }

    func selectMonth(_ date: Date) {
        selectedMonth = date
    }

    // MARK: - Existing Functions

    func fetchTransactions() {
        do {
            let descriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date, order: .reverse)])
            transactions = try modelContext.fetch(descriptor)

            // İlk yüklemede mevcut ayı seç
            if let currentMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) {
                selectedMonth = currentMonth
            }
        } catch {
            print("Failed to fetch transactions: \(error)")
            transactions = []
        }
    }

    func addTransaction(amount: Double, date: Date, type: TransactionType, category: TransactionCategory? = nil, note: String? = nil, installmentCount: Int? = nil, installmentPaymentDate: Date? = nil) {
        let transaction = Transaction(amount: amount, date: date, type: type, category: category, note: note, installmentCount: installmentCount, installmentPaymentDate: installmentPaymentDate)
        modelContext.insert(transaction)

        do {
            try modelContext.save()
            fetchTransactions() // Verileri yeniden yükle
        } catch {
            print("Failed to save transaction: \(error)")
        }
    }

    // MARK: - Analytics Functions

    func getIncomeVsExpenseData(for timeFrame: TransactionAnalyticsView.TimeFrame) -> [(String, Double, Double)] {
        let calendar = Calendar.current
        let now = Date()

        var filteredTransactions: [Transaction]
        let dateFormatter = DateFormatter()

        switch timeFrame {
        case .daily:
            dateFormatter.dateFormat = "HH:00"
            filteredTransactions = transactions.filter { calendar.isDate($0.date, inSameDayAs: now) }
        case .weekly:
            dateFormatter.dateFormat = "EEE"
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            filteredTransactions = transactions.filter { $0.date >= startOfWeek }
        case .monthly:
            dateFormatter.dateFormat = "dd MMM"
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            filteredTransactions = transactions.filter { $0.date >= startOfMonth }
        }

        var result: [(String, Double, Double)] = []

        let groupedTransactions = Dictionary(grouping: filteredTransactions) { transaction -> String in
            dateFormatter.string(from: transaction.date)
        }

        for (date, transactions) in groupedTransactions.sorted(by: { $0.key < $1.key }) {
            let income = transactions.filter { $0.type == .income }
                .reduce(0) { $0 + ($1.isInstallment ? ($1.installmentAmount ?? 0) : $1.amount) }
            let expense = transactions.filter { $0.type == .expense }
                .reduce(0) { $0 + ($1.isInstallment ? ($1.installmentAmount ?? 0) : $1.amount) }
            result.append((date, income, expense))
        }

        return result
    }

    func getExpensesByCategory(for timeFrame: TransactionAnalyticsView.TimeFrame) -> [(TransactionCategory, Double)] {
        let calendar = Calendar.current
        let now = Date()

        let filteredTransactions: [Transaction]
        switch timeFrame {
        case .daily:
            filteredTransactions = transactions.filter { calendar.isDate($0.date, inSameDayAs: now) }
        case .weekly:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            filteredTransactions = transactions.filter { $0.date >= startOfWeek }
        case .monthly:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            filteredTransactions = transactions.filter { $0.date >= startOfMonth }
        }

        let expenseTransactions = filteredTransactions.filter { $0.type == .expense }
        var categoryTotals: [TransactionCategory: Double] = [:]

        for transaction in expenseTransactions {
            if let category = transaction.category {
                let amount = transaction.isInstallment ? (transaction.installmentAmount ?? 0) : transaction.amount
                categoryTotals[category, default: 0] += amount
            }
        }

        return categoryTotals.map { ($0.key, $0.value) }.sorted { $0.1 > $1.1 }
    }

    // Yeni analiz fonksiyonları

    func getTotalInstallmentExpenses() -> Double {
        return transactions
            .filter { $0.type == .expense && $0.isInstallment }
            .reduce(0) { $0 + ($1.installmentAmount ?? 0) }
    }

    func getInstallmentsByCategory() -> [(TransactionCategory, Double)] {
        var categoryTotals: [TransactionCategory: Double] = [:]

        let installmentTransactions = transactions.filter { $0.type == .expense && $0.isInstallment }

        for transaction in installmentTransactions {
            if let category = transaction.category {
                categoryTotals[category, default: 0] += (transaction.installmentAmount ?? 0)
            }
        }

        return categoryTotals.map { ($0.key, $0.value) }.sorted { $0.1 > $1.1 }
    }

    func getRemainingInstallments() -> [(String, Double, Int)] {
        return transactions
            .filter { $0.type == .expense && $0.isInstallment }
            .map { ($0.note ?? "Taksitli Ödeme", $0.installmentAmount ?? 0, $0.installmentCount ?? 0) }
            .sorted { $0.1 > $1.1 }
    }

    func getInstallmentPaymentDate(for transaction: Transaction) -> Date? {
        transaction.installmentPaymentDate
    }

    func updateInstallmentPaymentDate(for transaction: Transaction, newDate: Date) {
        transaction.installmentPaymentDate = newDate

        do {
            try modelContext.save()
            fetchTransactions()
        } catch {
            print("Failed to update installment payment date: \(error)")
        }
    }

    func payInstallment(for transaction: Transaction) {
        guard transaction.isInstallment,
              transaction.remainingInstallments > 0 else { return }

        transaction.paidInstallments = (transaction.paidInstallments ?? 0) + 1

        do {
            try modelContext.save()
            fetchTransactions() // Verileri yeniden yükle
        } catch {
            print("Failed to update paid installments: \(error)")
        }
    }

    func getRemainingInstallments(for transaction: Transaction) -> Int {
        transaction.remainingInstallments
    }

    private func fetchData() {
        // Fetch data from modelContext
    }

    private func setupNotifications() {
        // Setup notifications
    }
}
