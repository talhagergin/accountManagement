import SwiftUI

struct AddPaymentCardView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var cards: [PaymentCard]
    @State private var name: String = ""
    @State private var last4Digits: String = ""
    var saveAction: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(.gray)
                        TextField("Kart Adı", text: $name)
                    }
                    HStack {
                        Image(systemName: "4.square.fill")
                            .foregroundColor(.gray)
                        TextField("Son 4 Hane", text: $last4Digits)
                            .keyboardType(.numberPad)
                    }
                }
                Button(action: {
                    let newCard = PaymentCard(name: name, last4Digits: last4Digits)
                    cards.append(newCard)
                    saveAction()
                    dismiss()
                }, label: {
                    HStack {
                        Spacer()
                        Text("Kaydet")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(8)
                })
            }
            .navigationTitle("Yeni Kart Ekle")
        }
    }
}
