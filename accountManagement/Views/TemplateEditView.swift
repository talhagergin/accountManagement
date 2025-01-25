// View/TemplateEditView.swift

import SwiftUI

struct TemplateEditView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var template: ExpenseTemplate
    @Binding var templates: [ExpenseTemplate]
    var saveAction: () -> Void
    var isNew: Bool = false
    
    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var category: TransactionCategory = .other
    @State private var note: String = ""
    @State private var type: TransactionType = .expense // Yeni: Şablon tipi

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "text.bubble.fill")
                            .foregroundColor(.gray)
                        TextField("Şablon Adı", text: $name)
                    }

                    HStack {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(.gray)
                        TextField("Miktar", text: $amount)
                            .keyboardType(.decimalPad)
                    }

                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.gray)
                        Picker("Kategori", selection: $category) {
                            ForEach(TransactionCategory.allCases, id: \.self) { category in
                                Label(category.rawValue, systemImage: category.icon)
                                    .tag(category)
                            }
                        }
                    }

                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.gray)
                        TextField("Açıklama", text: $note)
                    }
                    
                    HStack {
                        Image(systemName: "arrow.left.arrow.right")
                            .foregroundColor(.gray)
                        Picker("Şablon Tipi", selection: $type) {
                            ForEach(TransactionType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                    }
                }

                Button(action: {
                    let newTemplate = ExpenseTemplate(name: name, amount: amount, category: category, note: note, type: type)

                    if isNew {
                        templates.append(newTemplate)
                    } else {
                        template.name = name
                        template.amount = amount
                        template.category = category
                        template.note = note
                        template.type = type
                    }

                    saveAction()
                    dismiss()
                }, label: {
                    HStack {
                        Spacer()
                        Text(isNew ? "Ekle" : "Kaydet")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(8)
                })
            }
            .onAppear{
                name = template.name
                amount = template.amount
                category = template.category
                note = template.note
                type = template.type
            }
            .navigationTitle(isNew ? "Yeni Şablon" : "Şablon Düzenle")
        }
    }
}
