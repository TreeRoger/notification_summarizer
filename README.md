# Notification Summarizer

A multiplatform (iOS + macOS) app that helps you capture, organize, and intelligently summarize notifications and reminders. Built with SwiftUI for a modern, native experience on all Apple devices.

> **Resume Project** — Showcases SwiftUI, clean architecture, AI integration, and multiplatform development.

![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5-blue)

## Why This Approach?

Due to Apple's privacy-first design, **apps cannot access notifications from other applications** on iOS or macOS. This project takes a practical approach:

- **Quick-add inbox** — Capture notifications, reminders, and notes as they come in
- **Apple Reminders integration** — Pull in your existing reminders for summarization
- **AI-powered summaries** — Get intelligent digests using OpenAI (or mock mode for demos)
- **Beautiful native UI** — SwiftUI with platform-appropriate design

## Features

- 📱 **Multiplatform** — Single codebase for iPhone and Mac
- ⚡ **Quick add** — Capture items via shortcut, paste, or manual entry
- 🤖 **AI summarization** — Condense multiple items into actionable digests
- 📂 **Categories** — Organize by Work, Personal, Urgent, etc.
- 🔄 **Apple Reminders sync** — Import reminders for summarization (optional)
- 🌙 **Dark/Light mode** — Respects system appearance

## Tech Stack

- **SwiftUI** — Declarative UI, multiplatform
- **Swift Concurrency** — async/await, actors
- **SwiftData** — Persistent storage (iOS 17+ / macOS 14+)
- **OpenAI API** — Summarization (user provides API key)
- **Combine** — Reactive data flow where needed

## Requirements

- Xcode 15+
- iOS 17+ / macOS 14+
- OpenAI API key (optional — app works in demo mode without it)

## Setup

### Option A: Generate with XcodeGen (recommended)

```bash
brew install xcodegen
cd notification_summarizer
xcodegen generate
open NotificationSummarizer.xcodeproj
```

### Option B: Create project manually in Xcode

1. **New Project** → Multiplatform → App → Name: `NotificationSummarizer`
2. **Add existing files**: Drag the `NotificationSummarizer` folder into the project (ensure "Copy items if needed" is unchecked, "Create groups" selected)
3. **Add Info.plist** → Target → Info → add key `Privacy - Reminders Usage Description` with value: "Notification Summarizer needs access to your reminders to import and summarize them."
4. **Ensure deployment targets**: iOS 17+, macOS 14+

### Run

1. **Select scheme** — "NotificationSummarizer (iOS)" or "NotificationSummarizer (macOS)"
2. **Run** — ⌘R
3. **Add API key** (optional) — In app Settings, add your OpenAI API key for AI summarization. Without it, the app uses a built-in rule-based summarizer.

## Project Structure

```
NotificationSummarizer/
├── App/
│   └── NotificationSummarizerApp.swift    # App entry point
├── Models/
│   └── NotificationItem.swift             # Data model
├── Services/
│   ├── SummarizationService.swift         # AI summarization
│   └── RemindersService.swift             # Apple Reminders integration
├── Views/
│   ├── ContentView.swift
│   ├── AddItemView.swift
│   ├── SummaryView.swift
│   └── SettingsView.swift
├── ViewModels/
│   └── NotificationViewModel.swift
└── Resources/
    └── Assets.xcassets
```

## Architecture

- **MVVM** — Views observe ViewModels; ViewModels coordinate Services
- **Dependency injection** — Services injected for testability
- **SwiftData** — Persistence with `@Model` and `ModelContext`

## License

MIT — Feel free to use this as a portfolio piece or learning resource.
