import Foundation

enum Config {
    static let geminiAPIKey: String = fetch("GEMINI_API_KEY")
    static let supabaseURL: String = fetch("SUPABASE_URL")
    static let supabaseKey: String = fetch("SUPABASE_KEY")

    private static func fetch(_ key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            fatalError("Couldn't find key '\(key)' in Info.plist.")
        }
        return value
    }
}
