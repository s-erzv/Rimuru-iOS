import Foundation

// Daftar semua kemampuan Rimuru
enum AIActionType: String, Codable {
    case scheduleCreate = "SCHEDULE_CREATE"
    case scheduleRead = "SCHEDULE_READ"
    case taskCreate = "TASK_CREATE"
    case financeInsert = "FINANCE_INSERT"
    case financeReport = "FINANCE_REPORT"
}

// Struktur 1 Operasi
struct AIOperation: Codable {
    let action: AIActionType
    let payload: [String: String]
}

// Output final dari Gemini
struct AIResponse: Codable {
    let reply: String
    let operations: [AIOperation]
}

// Model untuk UI Chat
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}
