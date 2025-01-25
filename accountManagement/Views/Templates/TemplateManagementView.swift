// View/TemplateManagementView.swift

import SwiftUI

struct TemplateManagementView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var templates: [ExpenseTemplate]
    @State private var showAddTemplate = false
    var saveAction: () -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach($templates) { $template in
                    NavigationLink(destination: TemplateEditView(template: $template, templates: $templates, saveAction: saveAction)) {
                        HStack{
                            Text(template.name)
                            Spacer()
                            Text(template.type.rawValue)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: deleteTemplate)
            }
            .navigationTitle("Şablonları Yönet")
            .navigationBarItems(
                leading: Button("İptal", action: { dismiss() }),
                trailing: Button(action: { showAddTemplate = true }, label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                })
            )
            .sheet(isPresented: $showAddTemplate) {
                TemplateEditView(template: .constant(ExpenseTemplate(name: "", amount: "", category: .other, note: "", type: .expense)), templates: $templates, saveAction: saveAction, isNew: true)
            }
        }
    }

    private func deleteTemplate(at offsets: IndexSet){
        templates.remove(atOffsets: offsets)
        saveAction()
    }
}
