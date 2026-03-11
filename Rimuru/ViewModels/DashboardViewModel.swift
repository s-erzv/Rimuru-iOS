import Foundation
import Observation
import Supabase
import GoogleSignIn

@Observable
class DashboardViewModel {
    var schedules: [GoogleCalendarEvent] = []
    var upcomingSchedules: [GoogleCalendarEvent] = []
    var tasks: [RimuruTask] = []
    var totalIncome: Double = 0
    var totalExpense: Double = 0
    var balance: Double { totalIncome - totalExpense }
    var isLoading = false

    func fetchDashboardData() async {
        isLoading = true
        defer { isLoading = false }
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchGoogleData() }
            group.addTask { await self.fetchSupabaseFinances() }
        }
    }

    private func fetchGoogleData() async {
        guard let user = GIDSignIn.sharedInstance.currentUser else { return }
        do {
            let result = try await user.refreshTokensIfNeeded()
            let token = result.accessToken.tokenString
            
            // Fetch Calendar & Tasks parallel
            async let calendarData = fetchFromGoogle(url: "https://www.googleapis.com/calendar/v3/calendars/primary/events", token: token)
            async let tasksData = fetchFromGoogle(url: "https://www.googleapis.com/tasks/v1/lists/@default/tasks", token: token)
            
            if let cData = await calendarData {
                let res = try JSONDecoder().decode(GoogleCalendarResponse.self, from: cData)
                self.schedules = res.items.filter { isToday($0.start.dateTime) }
                self.upcomingSchedules = res.items.filter { !isToday($0.start.dateTime) }
            }
            
            if let tData = await tasksData {
                let res = try JSONDecoder().decode(GoogleTasksResponse.self, from: tData)
                self.tasks = res.items ?? []
            }
        } catch { print("Google API Error: \(error)") }
    }
    
    // Helper method for API calls
    private func fetchFromGoogle(url: String, token: String) async -> Data? {
        guard let url = URL(string: url) else { return nil }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return try? await URLSession.shared.data(for: req).0
    }
    
    private func isToday(_ dateString: String?) -> Bool {
        guard let dateString = dateString else { return false }
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return false }
        return Calendar.current.isDateInToday(date)
    }

    private func fetchSupabaseFinances() async {
        do {
            let finances: [FinanceDTO] = try await SupabaseService.shared.client.from("finances").select().execute().value
            self.totalIncome = finances.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
            self.totalExpense = finances.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
        } catch { print("Finance Error: \(error)") }
    }
}
