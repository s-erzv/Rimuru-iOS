import Foundation
import GoogleGenerativeAI

final class GeminiService {
    static let shared = GeminiService()
    private let model: GenerativeModel
    
    private init() {
        // 1. THE BULLETPROOF SCHEMA (Kunci 100% Anti-Halusinasi)
        // Kita paksa Gemini untuk SELALU mengeluarkan ke-6 key ini di dalam payload.
        // Tidak boleh ada yang terlewat, tidak boleh ada key tambahan.
        let payloadSchema = Schema(
            type: .object,
            properties: [
                "amount": Schema(type: .string, description: "Numeric only (e.g., '15000'). Use \"\" if not finance."),
                "type": Schema(type: .string, description: "Strictly 'income' or 'expense'. Use \"\" if not finance."),
                "item": Schema(type: .string, description: "Transaction name. Use \"\" if not finance."),
                "date": Schema(type: .string, description: "Strictly YYYY-MM-DDTHH:mm:ss. Calculate from CURRENT DATE. Use \"\" if not schedule."),
                "title": Schema(type: .string, description: "Event or task title. Use \"\" if not schedule or task."),
                "due": Schema(type: .string, description: "Strictly YYYY-MM-DD. Use \"\" if not task.")
            ],
            // INI KUNCINYA CU! Kita paksa AI gak boleh nge-skip satupun.
            requiredProperties: ["amount", "type", "item", "date", "title", "due"]
        )
        
        let responseSchema = Schema(
            type: .object,
            properties: [
                "reply": Schema(type: .string, description: "Natural conversational reply as Rimuru."),
                "operations": Schema(
                    type: .array,
                    items: Schema(
                        type: .object,
                        properties: [
                            "action": Schema(type: .string),
                            "payload": payloadSchema
                        ],
                        requiredProperties: ["action", "payload"]
                    )
                )
            ],
            requiredProperties: ["reply", "operations"]
        )
        
        let config = GenerationConfig(
            temperature: 0.1, // Rendah = Logika matematika & parsing lebih jalan
            responseMIMEType: "application/json",
            responseSchema: responseSchema
        )
        
        // 2. SYSTEM INSTRUCTION (Prompt Engineering Level Dewa)
        let systemInstruction = """
        You are Rimuru, an elite AI assistant for Nupers. Parse intent into an array of JSON operations.
        
        CRITICAL RULES:
        1. UNDERSTAND CONTEXT: "Jajan", "Makan", "Beli" = FINANCE_INSERT (expense). "Gajian", "Dikasih duit" = FINANCE_INSERT (income).
        2. SMART DATES: Calculate dates and times EXACTLY based on the CURRENT DATE & TIME provided in the prompt. "Besok jam 10 pagi" must be converted to exact YYYY-MM-DDTHH:mm:ss.
        3. PAYLOAD RULES: You MUST include ALL keys in the payload. If a key is not relevant to the action, fill it with an empty string "".
        4. MULTI-INTENT: If user gives multiple tasks in one prompt, create multiple objects in the 'operations' array.
        
        EXAMPLES:
        User: "Tadi abis makan batagor 15 ribu trus besok ada meeting jam 10 pagi"
        Output: 
        {
          "reply": "Siap Nupers, pengeluaran batagor 15 ribu udah gue catat, dan meeting besok jam 10 pagi udah gue masukin kalender.", 
          "operations": [
            {
              "action": "FINANCE_INSERT", 
              "payload": {"amount": "15000", "type": "expense", "item": "Makan batagor", "date": "", "title": "", "due": ""}
            },
            {
              "action": "SCHEDULE_CREATE", 
              "payload": {"amount": "", "type": "", "item": "", "date": "2026-03-06T10:00:00", "title": "Meeting", "due": ""}
            }
          ]
        }
        """
        
        self.model = GenerativeModel(
            name: "gemini-2.5-pro",
            apiKey: Config.geminiAPIKey,
            generationConfig: config,
            systemInstruction: ModelContent(role: "system", parts: [.text(systemInstruction)])
        )
    }
    
    func interpret(_ prompt: String) async -> AIResponse? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone.current
        let currentTime = formatter.string(from: Date())
        
        let enrichedPrompt = "CURRENT DATE & TIME: \(currentTime) (\(TimeZone.current.identifier)).\nUser: \(prompt)"
        
        do {
            let response = try await model.generateContent(enrichedPrompt)
            guard let text = response.text, let data = text.data(using: .utf8) else { return nil }
            
            print("📦 AI Response JSON:\n\(text)") // Cek Console, formatnya pasti rapi sekarang
            return try JSONDecoder().decode(AIResponse.self, from: data)
            
        } catch {
            print("🧠 AI Interpretation Error: \(error)")
            return nil
        }
    }
}
