import SwiftUI
import Charts

struct TransactionAnalyticsView: View {
    @State private var selectedTimeFrame: TimeFrame = .daily
    let viewModel: TransactionViewModel
    
    enum TimeFrame {
        case daily, weekly, monthly
        
        var title: String {
            switch self {
            case .daily: return "Günlük"
            case .weekly: return "Haftalık"
            case .monthly: return "Aylık"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Zaman Aralığı Seçici
                    Picker("Zaman Aralığı", selection: $selectedTimeFrame) {
                        Text("Günlük").tag(TimeFrame.daily)
                        Text("Haftalık").tag(TimeFrame.weekly)
                        Text("Aylık").tag(TimeFrame.monthly)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Gelir vs Gider Grafiği
                    ChartView(title: "Gelir ve Gider Karşılaştırması",
                             data: viewModel.getIncomeVsExpenseData(for: selectedTimeFrame))
                    
                    // Kategori Bazlı Gider Grafiği
                    if !viewModel.getExpensesByCategory(for: selectedTimeFrame).isEmpty {
                        CategoryChartView(title: "Kategorilere Göre Giderler",
                                       data: viewModel.getExpensesByCategory(for: selectedTimeFrame))
                    }
                    
                    // Taksitli Ödemeler Özeti
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Taksitli Ödemeler")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Toplam Taksitli Ödeme:")
                                Spacer()
                                Text("₺\(String(format: "%.2f", viewModel.getTotalInstallmentExpenses()))")
                                    .bold()
                            }
                            
                            Divider()
                            
                            Text("Taksitli Ödemeler Listesi:")
                                .font(.subheadline)
                            
                            ForEach(viewModel.getRemainingInstallments(), id: \.0) { item in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.0)
                                            .font(.subheadline)
                                        Text("Aylık Taksit: ₺\(String(format: "%.2f", item.1))")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text("\(item.2) Taksit")
                                        .font(.caption)
                                        .padding(5)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(5)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("Analiz")
        }
    }
}

struct ChartView: View {
    let title: String
    let data: [(String, Double, Double)] // (label, income, expense)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            
            Chart {
                ForEach(data, id: \.0) { item in
                    BarMark(
                        x: .value("Tarih", item.0),
                        y: .value("Tutar", item.1),
                        width: .ratio(0.3)
                    )
                    .foregroundStyle(.green)
                    .position(by: .value("Tür", "Gelir"))
                    
                    BarMark(
                        x: .value("Tarih", item.0),
                        y: .value("Tutar", item.2),
                        width: .ratio(0.3)
                    )
                    .foregroundStyle(.red)
                    .position(by: .value("Tür", "Gider"))
                }
            }
            .frame(height: 200)
            .chartLegend(position: .bottom)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct CategoryChartView: View {
    let title: String
    let data: [(TransactionCategory, Double)] // (category, amount)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            
            Chart {
                ForEach(data, id: \.0) { item in
                    SectorMark(
                        angle: .value("Tutar", item.1),
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    )
                    .cornerRadius(5)
                    .foregroundStyle(by: .value("Kategori", item.0.rawValue))
                }
            }
            .frame(height: 200)
            .chartLegend(position: .bottom)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
