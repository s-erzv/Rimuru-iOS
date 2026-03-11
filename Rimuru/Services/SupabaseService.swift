import Foundation
import Supabase
import Auth

class SupabaseService {
    static let shared = SupabaseService()
    
    let client = SupabaseClient(
        supabaseURL: URL(string: Config.supabaseURL)!,
        supabaseKey: Config.supabaseKey,
        options: SupabaseClientOptions(
            auth: .init(
                emitLocalSessionAsInitialSession: true
            )
        )
    )
            
    private init() {}
}
