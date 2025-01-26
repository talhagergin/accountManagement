import SwiftUI
import PDFKit
import SwiftData

class ReportViewModel: ObservableObject {
    let modelContext: ModelContext
    @Published var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @Published var endDate: Date = Date()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func setCurrentMonth() {
        let calendar = Calendar.current
        let now = Date()
        if let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) {
            startDate = startOfMonth
            endDate = now
        }
    }
    
    func setPreviousMonth() {
        let calendar = Calendar.current
        let now = Date()
        if let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
           let startOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: startOfCurrentMonth),
           let endOfPreviousMonth = calendar.date(byAdding: .day, value: -1, to: startOfCurrentMonth) {
            startDate = startOfPreviousMonth
            endDate = endOfPreviousMonth
        }
    }
    
    func setLast3Months() {
        let calendar = Calendar.current
        let now = Date()
        if let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) {
            startDate = threeMonthsAgo
            endDate = now
        }
    }
    
    func setCurrentYear() {
        let calendar = Calendar.current
        let now = Date()
        if let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now)) {
            startDate = startOfYear
            endDate = now
        }
    }
    
    func generateReport() -> Data? {
        do {
            let descriptor = FetchDescriptor<Transaction>(
                sortBy: [SortDescriptor(\.date)]
            )
            
            var transactions = try modelContext.fetch(descriptor)
            transactions = transactions.filter { transaction in
                transaction.date >= startDate && transaction.date <= endDate
            }
            
            // Calculate totals
            let totalIncome = transactions
                .filter { $0.type == .income }
                .reduce(0) { $0 + ($1.isInstallment ? ($1.installmentAmount ?? 0) : $1.amount) }
            
            let totalExpense = transactions
                .filter { $0.type == .expense }
                .reduce(0) { $0 + ($1.isInstallment ? ($1.installmentAmount ?? 0) : $1.amount) }
            
            // Group transactions by type and category
            let incomeByCategory = Dictionary(grouping: transactions.filter { $0.type == .income }) { $0.category?.rawValue ?? "Diğer" }
            let expenseByCategory = Dictionary(grouping: transactions.filter { $0.type == .expense }) { $0.category?.rawValue ?? "Diğer" }
            
            // Create PDF
            let pdfMetaData = [
                kCGPDFContextCreator: "AccountManagement App",
                kCGPDFContextAuthor: "User"
            ]
            let format = UIGraphicsPDFRendererFormat()
            format.documentInfo = pdfMetaData as [String: Any]
            
            let pageWidth = 8.5 * 72.0
            let pageHeight = 11 * 72.0
            let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
            
            let data = renderer.pdfData { context in
                context.beginPage()
                
                // Fonts
                let titleFont = UIFont.boldSystemFont(ofSize: 28.0)
                let headerFont = UIFont.boldSystemFont(ofSize: 18.0)
                let normalFont = UIFont.systemFont(ofSize: 12.0)
                let boldFont = UIFont.boldSystemFont(ofSize: 12.0)
                
                // Colors
                let headerColor = UIColor(red: 0.2, green: 0.2, blue: 0.8, alpha: 1.0)
                let positiveColor = UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
                let negativeColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
                
                // Header
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long
                dateFormatter.locale = Locale.current // Use system locale
                let title = "Finansal Rapor"
                let dateRange = "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
                
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: titleFont,
                    .foregroundColor: headerColor
                ]
                
                title.draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)
                dateRange.draw(at: CGPoint(x: 50, y: 90), withAttributes: [.font: headerFont])
                
                // Summary Box
                let summaryRect = CGRect(x: 50, y: 130, width: pageWidth - 100, height: 100)
                let path = UIBezierPath(roundedRect: summaryRect, cornerRadius: 10)
                UIColor(white: 0.95, alpha: 1.0).setFill()
                path.fill()
                
                "Özet".draw(at: CGPoint(x: 70, y: 145), withAttributes: [.font: headerFont])
                
                let summaryText = """
                Toplam Gelir: ₺\(String(format: "%.2f", totalIncome))
                Toplam Gider: ₺\(String(format: "%.2f", totalExpense))
                Net Bakiye: ₺\(String(format: "%.2f", totalIncome - totalExpense))
                """
                
                let summaryStyle = NSMutableParagraphStyle()
                summaryStyle.lineSpacing = 10
                
                summaryText.draw(at: CGPoint(x: 70, y: 175), withAttributes: [
                    .font: boldFont,
                    .paragraphStyle: summaryStyle
                ])
                
                // Category Breakdown
                var yPosition: CGFloat = 260
                
                // Income Categories
                "Gelir Kategorileri".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                    .font: headerFont,
                    .foregroundColor: positiveColor
                ])
                
                yPosition += 30
                for (category, transactions) in incomeByCategory {
                    let total = transactions.reduce(0) { $0 + ($1.isInstallment ? ($1.installmentAmount ?? 0) : $1.amount) }
                    let categoryText = "\(category): ₺\(String(format: "%.2f", total))"
                    categoryText.draw(at: CGPoint(x: 70, y: yPosition), withAttributes: [.font: normalFont])
                    yPosition += 20
                }
                
                yPosition += 20
                
                // Expense Categories
                "Gider Kategorileri".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                    .font: headerFont,
                    .foregroundColor: negativeColor
                ])
                
                yPosition += 30
                for (category, transactions) in expenseByCategory {
                    let total = transactions.reduce(0) { $0 + ($1.isInstallment ? ($1.installmentAmount ?? 0) : $1.amount) }
                    let categoryText = "\(category): ₺\(String(format: "%.2f", total))"
                    categoryText.draw(at: CGPoint(x: 70, y: yPosition), withAttributes: [.font: normalFont])
                    yPosition += 20
                }
                
                // Detailed Transactions
                if yPosition > pageHeight - 100 {
                    context.beginPage()
                    yPosition = 50
                }
                
                yPosition += 30
                "İşlem Detayları".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [.font: headerFont])
                yPosition += 30
                
                for transaction in transactions.sorted(by: { $0.date > $1.date }) {
                    if yPosition > pageHeight - 100 {
                        context.beginPage()
                        yPosition = 50
                    }
                    
                    let amount = transaction.isInstallment ? (transaction.installmentAmount ?? 0) : transaction.amount
                    let transactionColor = transaction.type == .income ? positiveColor : negativeColor
                    
                    let dateString = dateFormatter.string(from: transaction.date)
                    let amountString = "₺\(String(format: "%.2f", amount))"
                    
                    let transactionText = """
                    Tarih: \(dateString)
                    Tür: \(transaction.type == .income ? "Gelir" : "Gider")
                    Kategori: \(transaction.category?.rawValue ?? "Diğer")
                    Tutar: \(amountString)
                    \(transaction.note?.isEmpty == false ? "Not: \(transaction.note!)" : "")
                    """
                    
                    let transactionStyle = NSMutableParagraphStyle()
                    transactionStyle.lineSpacing = 5
                    
                    let transactionRect = CGRect(x: 50, y: yPosition, width: pageWidth - 100, height: 100) // Increased height
                    let transactionPath = UIBezierPath(roundedRect: transactionRect, cornerRadius: 5)
                    UIColor(white: 0.97, alpha: 1.0).setFill()
                    transactionPath.fill()
                    
                    // Draw a colored bar on the left side based on transaction type
                    let barWidth: CGFloat = 4
                    let barRect = CGRect(x: 50, y: yPosition, width: barWidth, height: 100)
                    let barPath = UIBezierPath(roundedRect: barRect, cornerRadius: 2)
                    (transaction.type == .income ? positiveColor : negativeColor).setFill()
                    barPath.fill()
                    
                    let textRect = transactionRect.insetBy(dx: 20, dy: 10) // Increased left padding
                    transactionText.draw(in: textRect, withAttributes: [
                        .font: normalFont,
                        .paragraphStyle: transactionStyle,
                        .foregroundColor: UIColor.black
                    ])
                    
                    yPosition += 110 // Increased spacing between transactions
                }
            }
            
            return data
            
        } catch {
            print("Failed to generate report: \(error)")
            return nil
        }
    }
}
