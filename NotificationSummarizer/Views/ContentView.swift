//
//  ContentView.swift
//  NotificationSummarizer
//
//  Main tabbed interface for the notification summarizer.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = NotificationViewModel()
    @State private var selectedTab = 0
    @State private var showingAddSheet = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            InboxView(viewModel: viewModel, showingAddSheet: $showingAddSheet)
                .tabItem {
                    Label("Inbox", systemImage: "tray.full.fill")
                }
                .tag(0)
            
            SummaryView(viewModel: viewModel)
                .tabItem {
                    Label("Summary", systemImage: "doc.text.magnifyingglass")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .onAppear {
            viewModel.loadItems(modelContext: modelContext)
        }
    }
}

// MARK: - Inbox View

struct InboxView: View {
    
    var viewModel: NotificationViewModel
    @Binding var showingAddSheet: Bool
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.items.isEmpty {
                    emptyState
                } else {
                    itemsList
                }
            }
            .navigationTitle("Inbox")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button {
                        Task {
                            await viewModel.importReminders(modelContext: modelContext)
                        }
                    } label: {
                        Image(systemName: "checklist")
                    }
                    .help("Import from Reminders")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddItemView { item in
                    viewModel.addItem(item, modelContext: modelContext)
                    showingAddSheet = false
                }
            }
        }
    }
    
    private var emptyState: some View {
        ContentUnavailableView {
            Label("No notifications yet", systemImage: "bell.slash")
        } description: {
            Text("Add notifications manually or import from Reminders")
        } actions: {
            Button("Add notification") {
                showingAddSheet = true
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var itemsList: some View {
        List {
            ForEach(viewModel.items, id: \.id) { item in
                NotificationRowView(item: item)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.deleteItem(item, modelContext: modelContext)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            viewModel.toggleStarred(item, modelContext: modelContext)
                        } label: {
                            Label(
                                item.isStarred ? "Unstar" : "Star",
                                systemImage: item.isStarred ? "star.slash" : "star.fill"
                            )
                        }
                        .tint(.yellow)
                    }
            }
        }
    }
}

// MARK: - Notification Row

struct NotificationRowView: View {
    let item: NotificationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(1)
                if item.isStarred {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
                Spacer()
                Text(item.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let body = item.body, !body.isEmpty {
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Text(item.category)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(CategoryBadgeStyle.color(for: item.category))
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}

struct CategoryBadgeStyle {
    static func color(for category: String) -> Color {
        switch category {
        case "Urgent": return .red.opacity(0.3)
        case "Work": return .blue.opacity(0.3)
        case "Personal": return .green.opacity(0.3)
        case "Social": return .purple.opacity(0.3)
        case "Finance": return .orange.opacity(0.3)
        default: return .gray.opacity(0.3)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: NotificationItem.self, inMemory: true)
}
