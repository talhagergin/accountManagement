// View/AddSubscriptionView.swift

import SwiftUI

struct AddSubscriptionView: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var monthlyCost: String = ""
    @State private var startDate: Date = Date()
    @State private var selectedFrequency: PaymentFrequency = .monthly
    @State private var selectedPaymentCard: PaymentCard?
    @State private var showingAddCardSheet = false
    
    @AppStorage("savedPaymentCards") private var savedPaymentCardsData: Data = Data()
    @State private var savedPaymentCards: [PaymentCard] = []
    
    var subscription: Subscription?
    
    var isEditing: Bool {
        subscription != nil
    }
    
    
    func loadCards(){
        if let decoded = try? JSONDecoder().decode([PaymentCard].self, from: savedPaymentCardsData) {
            savedPaymentCards = decoded
        }
        
    }
    
    func saveCards(){
        if let encoded = try? JSONEncoder().encode(savedPaymentCards) {
            savedPaymentCardsData = encoded
        }
        
    }
    
    init(viewModel: SubscriptionViewModel, subscription: Subscription? = nil) {
        self.viewModel = viewModel
        self.subscription = subscription
        
        if let subscription = subscription {
            _name = State(initialValue: subscription.name)
            _monthlyCost = State(initialValue: String(subscription.monthlyCost))
            _startDate = State(initialValue: subscription.startDate)
            _selectedFrequency = State(initialValue: subscription.paymentFrequency)
            _selectedPaymentCard = State(initialValue: subscription.paymentCard )
            
        }
        loadCards()
    }
    
      private var isFormValid: Bool {
            !name.isEmpty && !monthlyCost.isEmpty && Double(monthlyCost) != nil
        }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Abonelik Detayları")) {
                    HStack {
                        Image(systemName: "tag.fill")
                            .foregroundColor(.gray)
                        TextField("Abonelik Adı", text: $name)
                    }
                    
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(.gray)
                        TextField("Aylık Ücret", text: $monthlyCost)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        DatePicker("Başlangıç Tarihi", selection: $startDate, displayedComponents: .date)
                    }
                    
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(.gray)
                        Picker("Ödeme Sıklığı", selection: $selectedFrequency) {
                            ForEach(PaymentFrequency.allCases) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                    }
                    
                    HStack {
                        Image(systemName: "creditcard")
                            .foregroundColor(.gray)
                        Picker("Ödeme Kartı", selection: $selectedPaymentCard) {
                            Text("Seçiniz").tag(nil as PaymentCard?)
                            ForEach(savedPaymentCards) { card in
                                Text("\(card.name) - \(card.last4Digits)").tag(card as PaymentCard?)
                                
                            }
                        }
                        
                    }
                    Button("Yeni Kart Ekle") {
                        showingAddCardSheet = true
                    }
                }
                
                Button(action: {
                    if let cost = Double(monthlyCost) {
                        if isEditing, let subscription = subscription {
                            viewModel.updateSubscription(
                                subscription: subscription,
                                name: name,
                                monthlyCost: cost,
                                startDate: startDate,
                                paymentFrequency: selectedFrequency,
                                paymentCard: selectedPaymentCard
                            )
                        } else {
                            viewModel.addSubscription(
                                name: name,
                                monthlyCost: cost,
                                startDate: startDate,
                                paymentFrequency: selectedFrequency,
                                paymentCard: selectedPaymentCard
                            )
                        }
                        dismiss()
                    }
                }, label: {
                    HStack {
                        Spacer()
                        Text(isEditing ? "Güncelle" : "Kaydet")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(8)
                })
                 .disabled(!isFormValid)
            }
            .navigationTitle(isEditing ? "Aboneliği Düzenle" : "Abonelik Ekle")
            .navigationBarItems(
                leading: Button("İptal") {
                    dismiss()
                }
            )
            .sheet(isPresented: $showingAddCardSheet, content: {
                AddPaymentCardView(cards: $savedPaymentCards, saveAction: saveCards)
            })
            .onAppear{
                loadCards()
            }
        }
    }
}
