//
//  NotificationViewModel.swift
//  NotificationSummarizer
//
//  Coordinates data and business logic for the notification inbox.
//

import Foundation
import SwiftData

@MainActor
@Observable
class NotificationViewModel {
    
    var items: [NotificationItem] = []
    var summary: String = ""
    var isLoading = false
    var errorMessage: String?
    
    private let summarizationService: SummarizationService
    private let remindersService: RemindersService
    
    init(summarizationService: SummarizationService = SummarizationService(),
         remindersService: RemindersService = RemindersService()) {
        self.summarizationService = summarizationService
        self.remindersService = remindersService
    }
    
    func loadItems(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<NotificationItem>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        items = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func addItem(_ item: NotificationItem, modelContext: ModelContext) {
        modelContext.insert(item)
        items.insert(item, at: 0)
        try? modelContext.save()
    }
    
    func deleteItem(_ item: NotificationItem, modelContext: ModelContext) {
        modelContext.delete(item)
        items.removeAll { $0.id == item.id }
        try? modelContext.save()
    }
    
    func deleteItems(at offsets: IndexSet, modelContext: ModelContext) {
        for index in offsets {
            if index < items.count {
                let item = items[index]
                modelContext.delete(item)
                items.remove(at: index)
            }
        }
        try? modelContext.save()
    }
    
    func toggleStarred(_ item: NotificationItem, modelContext: ModelContext) {
        item.isStarred.toggle()
        try? modelContext.save()
    }
    
    func generateSummary(modelContext: ModelContext) async {
        guard !items.isEmpty else {
            summary = "Add some notifications first."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await summarizationService.summarize(items: items)
            summary = result
        } catch {
            errorMessage = error.localizedDescription
            summary = ""
        }
        
        isLoading = false
    }
    
    func importReminders() async {
        let granted = await remindersService.requestAccess()
        guard granted else {
            errorMessage = "Reminders access was denied."
            return
        }
        
        isLoading = true
        let reminderItems = await remindersService.fetchUpcomingReminders()
        isLoading = false
        
        // Items need to be added via modelContext - we'll need to pass it
        // For now, we return them and let the caller add
        _ = reminderItems
    }
    
    func importReminders(modelContext: ModelContext) async {
        let granted = await remindersService.requestAccess()
        guard granted else {
            errorMessage = "Reminders access was denied."
            return
        }
        
        isLoading = true
        let reminderItems = await remindersService.fetchUpcomingReminders()
        
        for item in reminderItems {
            modelContext.insert(item)
            items.insert(item, at: 0)
        }
        try? modelContext.save()
        isLoading = false
    }
    
    func configureSummarization(apiKey: String?) {
        // Would need to recreate service with new key - for now summary uses
        // the key from UserDefaults when generating
    }
}
