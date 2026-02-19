# Quick Setup Guide

## Prerequisites
- Xcode 15 or later
- macOS 14+ (for building)

## Generate Xcode Project

If you have [XcodeGen](https://github.com/yonaskolb/XcodeGen) installed:

```bash
cd notification_summarizer
xcodegen generate
open NotificationSummarizer.xcodeproj
```

**Install XcodeGen:** `brew install xcodegen`

---

## Manual Xcode Project Creation

If you prefer to create the project manually:

1. **Create new project**
   - File → New → Project
   - Choose **Multiplatform** → **App**
   - Product Name: `NotificationSummarizer`
   - Interface: SwiftUI
   - Language: Swift
   - Storage: SwiftData
   - Include Tests: optional

2. **Replace generated files**
   - Delete the default `ContentView.swift` and `Item` model (if any)
   - Drag the entire `NotificationSummarizer` folder from this repo into the Xcode project navigator
   - When prompted, select **Create groups** and ensure the app target is checked

3. **Configure target**
   - Select the project in the navigator
   - Under **Signing & Capabilities**, add **App Sandbox** (for macOS)
   - Under **Info** tab, add:
     - Key: `Privacy - Reminders Usage Description`
     - Value: `Notification Summarizer needs access to your reminders to import and summarize them.`

4. **Build and run**
   - Select iPhone or My Mac as destination
   - Press ⌘R

## Troubleshooting

**"No such module SwiftData"**  
Ensure deployment target is iOS 17+ / macOS 14+.

**Reminders import fails**  
Grant Reminders access when prompted, or check System Settings → Privacy & Security → Reminders.

**Summarization uses basic mode**  
Add your OpenAI API key in Settings for AI-powered summarization.
