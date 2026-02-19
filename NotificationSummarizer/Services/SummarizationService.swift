//
//  SummarizationService.swift
//  NotificationSummarizer
//
//  Handles AI-powered summarization via OpenAI API or fallback to rule-based summarizer.
//

import Foundation

actor SummarizationService {
    
    private let apiKey: String?
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init(apiKey: String? = nil) {
        self.apiKey = apiKey
    }
    
    func summarize(items: [NotificationItem], apiKeyOverride: String? = nil) async throws -> String {
        guard !items.isEmpty else {
            return "No notifications to summarize."
        }
        
        let key = apiKeyOverride ?? apiKey ?? UserDefaults.standard.string(forKey: "openai_api_key")
        if let key = key, !key.isEmpty {
            return try await summarizeWithOpenAI(items: items, apiKey: key)
        } else {
            return summarizeWithRules(items: items)
        }
    }
    
    // MARK: - OpenAI Integration
    
    private func summarizeWithOpenAI(items: [NotificationItem], apiKey: String) async throws -> String {
        let inputText = items.map { $0.displayText }.joined(separator: "\n\n---\n\n")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful assistant that summarizes notifications concisely. Create a brief, scannable summary. Use bullet points. Highlight urgent items. Keep it under 150 words."
                ],
                [
                    "role": "user",
                    "content": "Summarize these notifications:\n\n\(inputText)"
                ]
            ],
            "max_tokens": 300,
            "temperature": 0.5
        ]
        
        guard let url = URL(string: baseURL),
              let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw SummarizationError.invalidRequest
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SummarizationError.apiError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(OpenAIResponse.self, from: data)
        
        guard let content = result.choices.first?.message.content else {
            throw SummarizationError.emptyResponse
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Fallback Rule-based Summarizer
    
    private func summarizeWithRules(items: [NotificationItem]) -> String {
        var sections: [String] = []
        
        let urgent = items.filter { $0.category == "Urgent" }
        if !urgent.isEmpty {
            sections.append("**Urgent**")
            sections.append(urgent.map { "• \($0.title)" }.joined(separator: "\n"))
        }
        
        let work = items.filter { $0.category == "Work" }
        if !work.isEmpty {
            sections.append("\n**Work**")
            sections.append(work.map { "• \($0.title)" }.joined(separator: "\n"))
        }
        
        let personal = items.filter { ["Personal", "Finance"].contains($0.category) }
        if !personal.isEmpty {
            sections.append("\n**Personal**")
            sections.append(personal.map { "• \($0.title)" }.joined(separator: "\n"))
        }
        
        let other = items.filter { !["Urgent", "Work", "Personal", "Finance"].contains($0.category) }
        if !other.isEmpty {
            sections.append("\n**Other**")
            sections.append(other.map { "• \($0.title)" }.joined(separator: "\n"))
        }
        
        if sections.isEmpty {
            return "• \(items.map { $0.title }.joined(separator: "\n• "))"
        }
        
        return sections.joined(separator: "\n")
    }
}

// MARK: - Supporting Types

enum SummarizationError: LocalizedError {
    case invalidRequest
    case apiError(statusCode: Int)
    case emptyResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidRequest: return "Invalid request"
        case .apiError(let code): return "API error (status \(code))"
        case .emptyResponse: return "Empty response from API"
        }
    }
}

private struct OpenAIResponse: Decodable {
    let choices: [Choice]
    
    struct Choice: Decodable {
        let message: Message
    }
    
    struct Message: Decodable {
        let content: String
    }
}
