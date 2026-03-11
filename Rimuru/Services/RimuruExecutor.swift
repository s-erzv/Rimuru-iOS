import Foundation
import GoogleSignIn
import Supabase

class RimuruExecutor {
    static let shared = RimuruExecutor()
    private init() {}
    
    func execute(_ operations: [AIOperation]) async throws -> String? {
        var gatheredReports: [String] = []
        
        for op in operations {
            switch op.action {
            case .scheduleCreate: try await createCalendarEvent(payload: op.payload)
            case .scheduleRead:
                let report = try await readSchedule()
                gatheredReports.append(report)
            case .taskCreate: try await createTask(payload: op.payload)
            case .financeInsert: try await insertFinance(payload: op.payload)
            case .financeReport:
                let report = try await generateFinanceReport()
                gatheredReports.append(report)
            }
        }
        
        return gatheredReports.isEmpty ? nil : gatheredReports.joined(separator: "\n\n")
    }
    
    private func insertFinance(payload: [String: String]) async throws {
        let rawAmount = payload["amount"] ?? "0"
        let cleanAmountStr = rawAmount.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        let amount = Double(cleanAmountStr) ?? 0
        
        guard amount > 0 else { throw NSError(domain: "Execute", code: 400, userInfo: [NSLocalizedDescriptionKey: "Nominal 0."]) }
        
        let item = payload["item"] ?? "Transaksi"
        let rawType = (payload["type"] ?? "expense").lowercased()
        let type = ["income", "expense", "debt", "receivable", "prepaid"].contains(rawType) ? rawType : "expense"
        
        struct FinanceInsert: Encodable { let item: String; let amount: Double; let type: String }
        let entry = FinanceInsert(item: item, amount: amount, type: type)
        try await SupabaseService.shared.client.from("finances").insert(entry).execute()
    }
    
    // --- FINANCE REPORT ---
    private func generateFinanceReport() async throws -> String {
        let finances: [FinanceDTO] = try await SupabaseService.shared.client.from("finances").select().execute().value
        let income = finances.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
        let expense = finances.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
        let balance = income - expense
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency; formatter.currencyCode = "IDR"; formatter.maximumFractionDigits = 0
        
        return """
        📊 *Laporan Keuangan Lo Saat Ini:*
        🟢 Pemasukan: \(formatter.string(from: NSNumber(value: income)) ?? "Rp 0")
        🔴 Pengeluaran: \(formatter.string(from: NSNumber(value: expense)) ?? "Rp 0")
        💰 Saldo: \(formatter.string(from: NSNumber(value: balance)) ?? "Rp 0")
        """
    }
    
    // --- SCHEDULE CREATE ---
    private func createCalendarEvent(payload: [String: String]) async throws {
        let token = try await getGoogleToken()
        let title = payload["title"] ?? "Jadwal" // Judul hasil ekstrak AI
        let startTimeStr = payload["date"] ?? ""
        
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"; formatter.timeZone = TimeZone.current
        guard let startDate = formatter.date(from: startTimeStr) else { throw NSError(domain: "Execute", code: 400, userInfo: [NSLocalizedDescriptionKey: "Format waktu salah."]) }
        
        let endDate = startDate.addingTimeInterval(3600)
        
        let eventPayload: [String: Any] = [
            "summary": title,
            "start": ["dateTime": formatter.string(from: startDate), "timeZone": TimeZone.current.identifier],
            "end":   ["dateTime": formatter.string(from: endDate), "timeZone": TimeZone.current.identifier]
        ]
        
        guard let url = URL(string: "https://www.googleapis.com/calendar/v3/calendars/primary/events") else { return }
        var req = URLRequest(url: url); req.httpMethod = "POST"; req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization"); req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: eventPayload)
        
        let (_, res) = try await URLSession.shared.data(for: req)
        if let hRes = res as? HTTPURLResponse, hRes.statusCode != 200 { throw NSError(domain: "API", code: hRes.statusCode, userInfo: [NSLocalizedDescriptionKey: "Gagal API Calendar"]) }
    }
    
    // --- SCHEDULE READ ---
    private func readSchedule() async throws -> String {
        let token = try await getGoogleToken()
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let formatter = ISO8601DateFormatter()
        guard let url = URL(string: "https://www.googleapis.com/calendar/v3/calendars/primary/events?timeMin=\(formatter.string(from: startOfDay))&timeMax=\(formatter.string(from: endOfDay))&singleEvents=true&orderBy=startTime") else { return "URL Error" }
        
        var req = URLRequest(url: url); req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: req)
        let res = try JSONDecoder().decode(GoogleCalendarResponse.self, from: data)
        
        if res.items.isEmpty { return "Tidak ada jadwal hari ini, Nupers." }
        
        var reply = "🗓️ *Jadwal Lo Hari Ini:*\n"
        for event in res.items {
            let time = String(event.start.dateTime?.dropFirst(11).prefix(5) ?? "All Day")
            reply += "• \(time) - \(event.summary)\n"
        }
        return reply
    }
    
    // --- TASKS CREATE ---
    private func createTask(payload: [String: String]) async throws {
        let token = try await getGoogleToken()
        let title = payload["title"] ?? "Tugas Baru" // Ekstrak langsung dari chat user
        
        var bodyData: [String: Any] = ["title": title]
        // Wajib RFC3339 untuk Tasks API
        if let due = payload["due"], !due.isEmpty { bodyData["due"] = "\(due)T00:00:00.000Z" }
        
        guard let url = URL(string: "https://tasks.googleapis.com/tasks/v1/lists/@default/tasks") else { return }
        var req = URLRequest(url: url); req.httpMethod = "POST"; req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization"); req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: bodyData)
        
        let (_, res) = try await URLSession.shared.data(for: req)
        if let hRes = res as? HTTPURLResponse, hRes.statusCode != 200 { throw NSError(domain: "API", code: hRes.statusCode, userInfo: [NSLocalizedDescriptionKey: "Gagal Tasks API"]) }
    }
    
    // --- HELPER ---
    private func getGoogleToken() async throws -> String {
        guard let user = GIDSignIn.sharedInstance.currentUser else { throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Belum login."]) }
        return try await user.refreshTokensIfNeeded().accessToken.tokenString
    }
}
