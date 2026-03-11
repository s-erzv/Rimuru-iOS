import Foundation

struct GoogleCalendarResponse: Codable {
    let items: [GoogleCalendarEvent]
}

struct GoogleCalendarEvent: Codable, Identifiable {
    let id: String
    let summary: String
    let description: String?
    let start: EventTime
    let end: EventTime
    
    struct EventTime: Codable {
        let dateTime: String?
        let date: String?
    }
}

struct RimuruTask: Codable, Identifiable {
    let id: String
    let title: String
    let notes: String?
    let due: String?
    let status: String
}

struct GoogleTasksResponse: Codable {
    let items: [RimuruTask]?
}
