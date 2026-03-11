import Foundation
import Observation

@Observable
class ChatViewModel {
    var messages: [ChatMessage] = [
        ChatMessage(content: "System Online. I am Rimuru. What's our agenda, Nupers?", isUser: false)
    ]
    var isTyping = false
    
    func processInput(_ text: String) async {
        // 1. Render chat user ke UI
        messages.append(ChatMessage(content: text, isUser: true))
        isTyping = true
        
        // 2. Layer 1: Interpretasi Intent via Gemini
        guard let aiResponse = await GeminiService.shared.interpret(text) else {
            isTyping = false
            messages.append(ChatMessage(content: "Connection to cognitive network failed. Try again?", isUser: false))
            return
        }
        
        // 3. Layer 2: Eksekusi (HANYA pass 'operations'-nya saja ke Executor)
        do {
            // FIX: Kita pecah. aiResponse.operations dilempar ke Executor.
            let systemReports = try await RimuruExecutor.shared.execute(aiResponse.operations)
            
            // 4. UI Layer: Tampilkan 'reply' natural dari Gemini
            messages.append(ChatMessage(content: aiResponse.reply, isUser: false))
            
            // 5. Data Layer: Kalau eksekutor balikin data (misal list jadwal/laporan keuangan), tampilkan
            if let reports = systemReports {
                messages.append(ChatMessage(content: reports, isUser: false))
            }
            
        } catch {
            messages.append(ChatMessage(content: "⚠️ System Error during execution: \(error.localizedDescription)", isUser: false))
        }
        
        isTyping = false
    }
}
