import Foundation

enum Config {
    static let geminiAPIKey: String = {
        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let value = plist["GEMINI_API_KEY"] as? String else {
            fatalError("Couldn't find key 'GEMINI_API_KEY' in Info.plist.")
        }
        return value
    }()
}