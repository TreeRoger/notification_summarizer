//
//  SummaryView.swift
//  NotificationSummarizer
//
//  Displays AI-generated summary of captured notifications.
//

import SwiftUI
import SwiftData

struct SummaryView: View {
    
    var viewModel: NotificationViewModel
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("Summarizing...")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                    } else if !viewModel.summary.isEmpty {
                        summaryCard
                    } else {
                        emptyState
                    }
                    
                    if let error = viewModel.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Summary")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await viewModel.generateSummary(modelContext: modelContext)
                        }
                    } label: {
                        Label("Summarize", systemImage: "sparkles")
                    }
                    .disabled(viewModel.items.isEmpty || viewModel.isLoading)
                }
            }
        }
    }
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text("Your digest")
                    .font(.headline)
            }
            
            Text(viewModel.summary)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var emptyState: some View {
        ContentUnavailableView {
            Label("No summary yet", systemImage: "sparkles")
        } description: {
            Text("Add notifications to your inbox, then tap Summarize to get an AI digest.")
        } actions: {
            Text("\(viewModel.items.count) items in inbox")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: NotificationItem.self, configurations: config)
    
    let vm = NotificationViewModel()
    for item in NotificationItem.sampleItems {
        container.mainContext.insert(item)
    }
    vm.loadItems(modelContext: container.mainContext)
    
    return SummaryView(viewModel: vm)
        .modelContainer(container)
}
