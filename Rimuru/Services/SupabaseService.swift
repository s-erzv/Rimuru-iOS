import Foundation
import Supabase
import Auth

class SupabaseService {
    static let shared = SupabaseService()
    
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://ntmjcruhwghqclkumbyu.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50bWpjcnVod2docWNsa3VtYnl1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA0MzM5NzksImV4cCI6MjA4NjAwOTk3OX0.PE7xIHTCdA8wbeuhMfJct27iBiDWAnZAeKtovjx6nUA",
        options: SupabaseClientOptions(
            auth: .init(
                emitLocalSessionAsInitialSession: true
            )
        )
    )
            
    private init() {}
}
