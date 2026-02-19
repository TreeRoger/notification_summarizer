//
//  RemindersService.swift
//  NotificationSummarizer
//
//  Fetches reminders from Apple Reminders for summarization.
//

import Foundation
import EventKit

@MainActor
class RemindersService: ObservableObject {
    
    private let eventStore = EKEventStore()
    
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    var isAuthorized: Bool {
        authorizationStatus == .fullAccess || authorizationStatus == .authorized
    }
    
    init() {
        updateAuthorizationStatus()
    }
    
    func requestAccess() async -> Bool {
        if #available(iOS 17.0, macOS 14.0, *) {
            do {
                let granted = try await eventStore.requestFullAccessToReminders()
                await MainActor.run { updateAuthorizationStatus() }
                return granted
            } catch {
                return false
            }
        } else {
            return await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .reminder) { [weak self] granted, _ in
                    Task { @MainActor in
                        self?.updateAuthorizationStatus()
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
    }
    
    func fetchUpcomingReminders(limit: Int = 50) async -> [NotificationItem] {
        guard isAuthorized else { return [] }
        
        let calendars = eventStore.calendars(for: .reminder)
        let predicate = eventStore.predicateForReminders(in: calendars)
        
        return await withCheckedContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                let items = (reminders ?? [])
                    .filter { !($0.isCompleted) }
                    .prefix(limit)
                    .map { reminder -> NotificationItem in
                        NotificationItem(
                            title: reminder.title ?? "Untitled",
                            body: reminder.notes,
                            sourceApp: "Reminders",
                            category: "Personal",
                            timestamp: reminder.dueDateComponents?.date ?? Date()
                        )
                    }
                continuation.resume(returning: Array(items))
            }
        }
    }
    
    private func updateAuthorizationStatus() {
        if #available(iOS 17.0, macOS 14.0, *) {
            authorizationStatus = EKEventStore.authorizationStatus(for: .reminder)
        } else {
            authorizationStatus = EKEventStore.authorizationStatus(for: .reminder)
        }
    }
}
