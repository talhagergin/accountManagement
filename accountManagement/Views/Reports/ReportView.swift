import SwiftUI
import SwiftData
import PDFKit

struct ReportView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ReportViewModel
    @State private var showingShareSheet = false
    @State private var pdfData: Data?
    @State private var showingDatePicker = false
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: ReportViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Date Range Selection
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Başlangıç Tarihi")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        DatePicker("", selection: $viewModel.startDate, displayedComponents: [.date])
                            .labelsHidden()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Bitiş Tarihi")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        DatePicker("", selection: $viewModel.endDate, displayedComponents: [.date])
                            .labelsHidden()
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                )
                
                // Quick Date Selection Buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        QuickDateButton(title: "Bu Ay", action: {
                            viewModel.setCurrentMonth()
                        })
                        
                        QuickDateButton(title: "Geçen Ay", action: {
                            viewModel.setPreviousMonth()
                        })
                        
                        QuickDateButton(title: "Son 3 Ay", action: {
                            viewModel.setLast3Months()
                        })
                        
                        QuickDateButton(title: "Bu Yıl", action: {
                            viewModel.setCurrentYear()
                        })
                    }
                    .padding(.horizontal)
                }
                
                // Generate Report Button
                Button(action: {
                    if let data = viewModel.generateReport() {
                        self.pdfData = data
                    }
                }) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                        Text("Rapor Oluştur")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // PDF Preview
                if let pdfData = pdfData {
                    PDFPreviewView(data: pdfData)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                        .overlay(
                            Button(action: {
                                self.showingShareSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Paylaş")
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .padding(),
                            alignment: .bottomTrailing
                        )
                } else {
                    Text("Rapor oluşturmak için yukarıdaki butona tıklayın")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
            .navigationTitle("Rapor Oluştur")
            .sheet(isPresented: $showingShareSheet) {
                if let data = pdfData {
                    ShareSheet(activityItems: [data])
                }
            }
        }
    }
}

struct PDFPreviewView: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .vertical
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let document = PDFDocument(data: data) {
            pdfView.document = document
        }
    }
}

struct QuickDateButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                )
                .foregroundColor(.blue)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
