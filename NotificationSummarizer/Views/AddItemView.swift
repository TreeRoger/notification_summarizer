//
//  AddItemView.swift
//  NotificationSummarizer
//
//  Quick-add form for capturing notifications.
//

import SwiftUI
import SwiftData

struct AddItemView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var bodyText = ""
    @State private var selectedCategory = "General"
    
    let onSave: (NotificationItem) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Notification") {
                    TextField("Title", text: $title, prompt: Text("e.g. Meeting at 3pm"))
                    TextField("Details (optional)", text: $bodyText, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(NotificationItem.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    #if os(iOS)
                    .pickerStyle(.segmented)
                    #else
                    .pickerStyle(.menu)
                    #endif
                }
            }
            .navigationTitle("Add Notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        save()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func save() {
        let item = NotificationItem(
            title: title.trimmingCharacters(in: .whitespaces),
            body: bodyText.isEmpty ? nil : bodyText.trimmingCharacters(in: .whitespaces),
            category: selectedCategory
        )
        onSave(item)
    }
}

#Preview {
    AddItemView { _ in }
}
