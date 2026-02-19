//
//  NotificationItem.swift
//  NotificationSummarizer
//
//  A captured notification or reminder for summarization.
//

import Foundation
import SwiftData

@Model
final class NotificationItem {
    
    var id: UUID
    var title: String
    var body: String?
    var sourceApp: String?
    var category: String
    var timestamp: Date
    var isRead: Bool
    var isStarred: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        body: String? = nil,
        sourceApp: String? = nil,
        category: String = "General",
        timestamp: Date = Date(),
        isRead: Bool = false,
        isStarred: Bool = false
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.sourceApp = sourceApp
        self.category = category
        self.timestamp = timestamp
        self.isRead = isRead
        self.isStarred = isStarred
    }
    
    var displayText: String {
        if let body = body, !body.isEmpty {
            return "\(title)\n\(body)"
        }
        return title
    }
}

extension NotificationItem {
    
    static let categories = ["General", "Work", "Personal", "Urgent", "Social", "Finance"]
    
    static var sampleItems: [NotificationItem] {
        [
            NotificationItem(title: "Meeting at 3pm", body: "Team sync with Design", category: "Work"),
            NotificationItem(title: "Package delivered", body: "Your order #1234 has arrived", category: "Personal"),
            NotificationItem(title: "Bill due tomorrow", body: "Electric bill $89 due Feb 19", category: "Urgent"),
            NotificationItem(title: "Sarah liked your post", category: "Social"),
            NotificationItem(title: "Payroll deposited", body: "$3,200 deposited to checking", category: "Finance")
        ]
    }
}
