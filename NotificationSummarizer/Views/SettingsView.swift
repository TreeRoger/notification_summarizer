//
//  SettingsView.swift
//  NotificationSummarizer
//
//  App settings including OpenAI API key configuration.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("openai_api_key") private var apiKey = ""
    @State private var showApiKey = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        if showApiKey {
                            TextField("API Key", text: $apiKey, prompt: Text("sk-..."))
                                .textContentType(.password)
                                .autocorrectionDisabled()
                        } else {
                            SecureField("API Key", text: $apiKey, prompt: Text("sk-..."))
                        }
                        Button {
                            showApiKey.toggle()
                        } label: {
                            Image(systemName: showApiKey ? "eye.slash" : "eye")
                        }
                    }
                    Text("Add your OpenAI API key for AI summarization. Leave empty to use the built-in summarizer.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("OpenAI")
                } footer: {
                    Link("Get an API key →", destination: URL(string: "https://platform.openai.com/api-keys")!)
                }
                
                Section {
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("GitHub", destination: URL(string: "https://github.com")!)
                } header: {
                    Text("About")
                }
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
